import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<RestaurantProvider>();
    final cart = context.watch<CartProvider>();
    final rest = prov.selected;

    if (prov.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: WajbaColors.primary)));
    }

    if (rest == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.error_outline, title: 'Restaurant introuvable'));
    }

    final categories = ['Tous', ...prov.productCategories];
    final products   = prov.productsByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: WajbaColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header image ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: WajbaColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: WajbaImage(
                rest.bannerUrl,
                height: 220, width: double.infinity,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Infos restaurant ──────────────────────────
                Container(
                  color: WajbaColors.white,
                  padding: const EdgeInsets.all(kPaddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rest.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                               color: WajbaColors.dark)),
                      const SizedBox(height: 4),
                      Text(rest.cuisine,
                        style: const TextStyle(color: WajbaColors.grey600)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 16, runSpacing: 8, children: [
                        _InfoChip(Icons.star,         '${rest.rating}',
                                  WajbaColors.warning),
                        _InfoChip(Icons.access_time,  '${rest.deliveryTime} min',
                                  WajbaColors.grey600),
                        _InfoChip(Icons.delivery_dining,
                          rest.deliveryFee == 0 ? 'Livraison gratuite'
                              : '${rest.deliveryFee} DA livraison',
                          WajbaColors.success),
                        _InfoChip(Icons.shopping_bag_outlined,
                          'Min ${rest.minOrder} DA', WajbaColors.grey600),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.location_on, size: 14,
                                   color: WajbaColors.grey600),
                        const SizedBox(width: 4),
                        Expanded(child: Text(rest.address,
                          style: const TextStyle(color: WajbaColors.grey600,
                                                  fontSize: 13))),
                      ]),
                    ],
                  ),
                ),

                // ── Catégories ────────────────────────────────
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: kPaddingM),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: categories[i],
                        selected: _selectedCategory == categories[i],
                        onTap: () => setState(() => _selectedCategory = categories[i]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Produits ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ProductCard(
                  product: products[i],
                  quantity: cart.quantityOf(products[i].id),
                  onAdd: () => cart.addItem(products[i], rest.id, rest.name),
                  onRemove: () => cart.removeItem(products[i].id),
                ),
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),

      // ── Bouton Voir panier ────────────────────────────────────
      bottomNavigationBar: cart.itemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(kPaddingM),
                child: WajbaButton(
                  label: 'Voir le panier • ${cart.subtotal} DA',
                  icon: Icons.shopping_bag,
                  onTap: () => context.push('/cart'),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InfoChip(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: color, fontSize: 13,
                                   fontWeight: FontWeight.w500)),
    ],
  );
}

class _ProductCard extends StatelessWidget {
  final Product  product;
  final int      quantity;
  final VoidCallback onAdd, onRemove;
  const _ProductCard({required this.product, required this.quantity,
                       required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(kPaddingM),
    decoration: BoxDecoration(
      color: WajbaColors.cardBg,
      borderRadius: BorderRadius.circular(kRadiusM),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                             blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusS),
          child: WajbaImage(product.imageUrl, width: 80, height: 80),
        ),
        const SizedBox(width: 12),
        // Infos
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.w600,
                                       color: WajbaColors.dark, fontSize: 15)),
              const SizedBox(height: 4),
              Text(product.description,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: WajbaColors.grey600, fontSize: 12)),
              const SizedBox(height: 8),
              Text('${product.price} DA',
                style: const TextStyle(color: WajbaColors.primary,
                                        fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Quantité
        if (quantity == 0)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WajbaColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: WajbaColors.white, size: 20),
            ),
          )
        else
          Row(
            children: [
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: WajbaColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, color: WajbaColors.primary, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$quantity',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                                          color: WajbaColors.dark, fontSize: 16)),
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: WajbaColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: WajbaColors.white, size: 16),
                ),
              ),
            ],
          ),
      ],
    ),
  );
}
