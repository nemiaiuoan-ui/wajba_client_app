import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final categoriesAsync = ref.watch(categoriesProvider);
    final filter = ref.watch(restaurantFilterProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider(filter));
    final address = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: WajbaColors.bgSecondary,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── App Bar ──────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 0,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.addresses),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: WajbaColors.primary, size: 14),
                              const SizedBox(width: 3),
                              const Text('Livrer à', style: TextStyle(fontSize: 10, color: WajbaColors.grey400, fontFamily: 'Cairo')),
                              const Icon(Icons.keyboard_arrow_down, size: 14, color: WajbaColors.grey500),
                            ],
                          ),
                          Text(
                            address?.commune ?? 'Choisir une adresse',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Notifications
                  Badge(
                    backgroundColor: WajbaColors.primary,
                    label: const Text('2'),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: WajbaColors.grey700),
                      onPressed: () => context.push(AppRoutes.notifications),
                    ),
                  ),
                  // Avatar
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: WajbaColors.primaryBg,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: WajbaColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: WajbaColors.grey100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: WajbaColors.grey400, size: 20),
                          SizedBox(width: 10),
                          Text('Restaurants, plats...', style: TextStyle(color: WajbaColors.grey400, fontSize: 14, fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Promo Banner ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20, bottom: -20,
                          child: Container(
                            width: 150, height: 150,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
                          ),
                        ),
                        Positioned(
                          right: 30, top: -30,
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                child: const Text('Offre du jour 🎉', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                              ),
                              const SizedBox(height: 8),
                              const Text('20% de réduction\nsur votre 1ère commande !', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.3, fontFamily: 'Cairo')),
                              const SizedBox(height: 4),
                              const Text('Code: WAJBA10', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                        const Positioned(right: 20, bottom: 16, child: Text('🍽️', style: TextStyle(fontSize: 60))),
                      ],
                    ),
                  ),
                ),

                // ── Categories ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
                  child: Row(
                    children: [
                      const Text('Catégories', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: WajbaColors.primary, fontFamily: 'Cairo'))),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 92,
                  child: categoriesAsync.when(
                    loading: () => _CategoryShimmer(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (cats) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => CategoryChip(
                        category: cats[i],
                        isSelected: _selectedCategory == cats[i].id,
                        onTap: () => setState(() {
                          _selectedCategory = _selectedCategory == cats[i].id ? null : cats[i].id;
                          ref.read(restaurantFilterProvider.notifier).update((f) => f.copyWith(categoryId: _selectedCategory));
                        }),
                      ),
                    ),
                  ),
                ),

                // ── Sort Bar ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Text('Restaurants', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                      const Spacer(),
                      _SortButton(
                        current: filter.sortBy,
                        onChanged: (v) => ref.read(restaurantFilterProvider.notifier).update((f) => f.copyWith(sortBy: v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Restaurant List ──────────────────────────
          restaurantsAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const _RestaurantShimmer(),
                childCount: 4,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('Erreur: $e', style: const TextStyle(color: WajbaColors.grey400, fontFamily: 'Cairo')),
              )),
            ),
            data: (restaurants) => restaurants.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(children: [
                          const Text('😔', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text('Aucun restaurant trouvé', style: TextStyle(fontSize: 16, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                        ]),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RestaurantCard(
                            restaurant: restaurants[i],
                            onTap: () => context.push('/restaurant/${restaurants[i].id}'),
                          ),
                        ),
                        childCount: restaurants.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Sort Button ──────────────────────────────────
class _SortButton extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _SortButton({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'rating', child: Text('⭐ Mieux notés', style: TextStyle(fontFamily: 'Cairo'))),
        const PopupMenuItem(value: 'distance', child: Text('📍 Plus proches', style: TextStyle(fontFamily: 'Cairo'))),
        const PopupMenuItem(value: 'delivery_time', child: Text('⚡ Livraison rapide', style: TextStyle(fontFamily: 'Cairo'))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: WajbaColors.primaryBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WajbaColors.primaryLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.sort, size: 14, color: WajbaColors.primary),
            const SizedBox(width: 4),
            Text(
              current == 'rating' ? 'Note' : current == 'distance' ? 'Distance' : 'Rapidité',
              style: const TextStyle(fontSize: 12, color: WajbaColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Loaders ──────────────────────────────
class _CategoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: WajbaColors.grey100, highlightColor: WajbaColors.grey50,
        child: Column(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(height: 6),
          Container(width: 48, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5))),
        ]),
      ),
    );
  }
}

class _RestaurantShimmer extends StatelessWidget {
  const _RestaurantShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Shimmer.fromColors(
        baseColor: WajbaColors.grey100, highlightColor: WajbaColors.grey50,
        child: Container(
          height: 220,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
