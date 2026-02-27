import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user         = context.watch<AuthProvider>().user;
    final restProvider = context.watch<RestaurantProvider>();
    final shown        = restProvider.search(_query);

    return Scaffold(
      backgroundColor: WajbaColors.background,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            backgroundColor: WajbaColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [WajbaColors.primaryDark, WajbaColors.primary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ${user?.name.split(' ').first ?? ''}! 👋',
                      style: const TextStyle(
                        color: WajbaColors.white, fontSize: 20,
                        fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text('Que voulez-vous manger aujourd\'hui ?',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: WajbaColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un restaurant...',
                    prefixIcon: Icon(Icons.search, color: WajbaColors.grey400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenu ──────────────────────────────────────────
          if (restProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: WajbaColors.primary)),
            )
          else if (restProvider.error.isNotEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: Icons.wifi_off,
                title: 'Connexion perdue',
                subtitle: restProvider.error,
                buttonLabel: 'Réessayer',
                onButton: () => restProvider.loadRestaurants(),
              ),
            )
          else if (shown.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.search_off,
                title: 'Aucun restaurant trouvé',
                subtitle: 'Essayez un autre terme de recherche',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(kPaddingM),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _RestaurantCard(restaurant: shown[i]),
                  childCount: shown.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
}

// ─── RESTAURANT CARD ──────────────────────────────────────────────
class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/restaurant/${restaurant.id}'),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: WajbaColors.cardBg,
        borderRadius: BorderRadius.circular(kRadiusL),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusL)),
                child: WajbaImage(
                  restaurant.bannerUrl,
                  height: 150, width: double.infinity,
                ),
              ),
              // Badge ouvert/fermé
              Positioned(top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: restaurant.isOpen ? WajbaColors.success : WajbaColors.grey600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    restaurant.isOpen ? '● Ouvert' : '● Fermé',
                    style: const TextStyle(color: WajbaColors.white,
                                           fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(kPaddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(restaurant.name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                               color: WajbaColors.dark)),
                    ),
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: WajbaColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.star, size: 14, color: WajbaColors.warning),
                        const SizedBox(width: 3),
                        Text(restaurant.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600,
                                                  color: WajbaColors.warning, fontSize: 13)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(restaurant.cuisine,
                  style: const TextStyle(color: WajbaColors.grey600, fontSize: 13)),
                const SizedBox(height: 12),
                // Infos livraison
                Row(
                  children: [
                    _Info(Icons.access_time, '${restaurant.deliveryTime} min'),
                    const SizedBox(width: 16),
                    _Info(Icons.delivery_dining,
                      restaurant.deliveryFee == 0 ? 'Gratuit'
                          : '${restaurant.deliveryFee} DA'),
                    const SizedBox(width: 16),
                    _Info(Icons.shopping_bag_outlined,
                      'Min ${restaurant.minOrder} DA'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _Info(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: WajbaColors.grey600),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: WajbaColors.grey600)),
    ],
  );
}
