import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  const RestaurantScreen({super.key, required this.restaurantId});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final _scrollCtrl = ScrollController();
  List<String> _categories = [];
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 1, vsync: this);
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 280;
      if (show != _showStickyHeader) setState(() => _showStickyHeader = show);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantDetailProvider(widget.restaurantId));
    final productsAsync = ref.watch(restaurantProductsProvider(widget.restaurantId));
    final cart = ref.watch(cartProvider);
    final cartCount = ref.watch(cartCountProvider);

    return restaurantAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: WajbaColors.primary))),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (restaurant) {
        return productsAsync.when(
          loading: () => _buildScaffold(restaurant, null, cart, cartCount),
          error: (e, _) => _buildScaffold(restaurant, [], cart, cartCount),
          data: (products) {
            // Update tab categories
            final cats = ['Tout', ...{...products.map((p) => p.category)}.toList()];
            if (_categories.isEmpty || _categories.length != cats.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _categories = cats;
                  _tabCtrl = TabController(length: cats.length, vsync: this);
                });
              });
            }
            return _buildScaffold(restaurant, products, cart, cartCount);
          },
        );
      },
    );
  }

  Widget _buildScaffold(RestaurantModel restaurant, List<ProductModel>? products, CartModel cart, int cartCount) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Banner + Info ─────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: WajbaColors.grey900),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18, color: WajbaColors.grey900),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: restaurant.banner != null
                      ? CachedNetworkImage(imageUrl: restaurant.banner!, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [WajbaColors.primary.withOpacity(0.2), WajbaColors.primaryDark.withOpacity(0.3)],
                            ),
                          ),
                          child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 80))),
                        ),
                ),
              ),

              // ── Restaurant Info Card ──────────────────
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: WajbaColors.grey50, border: Border.all(color: WajbaColors.grey100)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: restaurant.logo != null
                                  ? CachedNetworkImage(imageUrl: restaurant.logo!, fit: BoxFit.cover)
                                  : const Center(child: Text('🍽️', style: TextStyle(fontSize: 26))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(restaurant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                                    if (restaurant.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: WajbaColors.primary, size: 16),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(restaurant.cuisineType, style: const TextStyle(fontSize: 13, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: restaurant.isOpen ? WajbaColors.successBg : WajbaColors.errorBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              restaurant.isOpen ? '🟢 Ouvert' : '🔴 Fermé',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: restaurant.isOpen ? WajbaColors.success : WajbaColors.error, fontFamily: 'Cairo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Stats
                      Row(
                        children: [
                          _InfoTile(icon: '⭐', value: restaurant.ratingLabel, label: '${restaurant.reviewCount} avis'),
                          _divider(),
                          _InfoTile(icon: '⏱️', value: restaurant.deliveryTimeLabel, label: 'Livraison'),
                          _divider(),
                          _InfoTile(icon: '🛵', value: restaurant.deliveryFeeLabel, label: 'Frais'),
                          _divider(),
                          _InfoTile(icon: '🛒', value: '${restaurant.minOrder.toInt()} DZD', label: 'Min.'),
                        ],
                      ),
                      if (restaurant.promoTag != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: WajbaColors.primaryBg, borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: WajbaColors.primaryLight),
                          ),
                          child: Row(
                            children: [
                              const Text('🎁', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(restaurant.promoTag!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WajbaColors.primary, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Menu Tabs ─────────────────────────────
              if (_categories.length > 1)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabCtrl,
                      isScrollable: true,
                      labelColor: WajbaColors.primary,
                      unselectedLabelColor: WajbaColors.grey400,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Cairo', fontSize: 13),
                      indicatorColor: WajbaColors.primary,
                      indicatorWeight: 2.5,
                      tabs: _categories.map((c) => Tab(text: c)).toList(),
                    ),
                  ),
                ),

              // ── Products ──────────────────────────────
              if (products == null)
                SliverToBoxAdapter(child: const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: WajbaColors.primary))))
              else if (products.isEmpty)
                SliverToBoxAdapter(child: const Center(child: Padding(padding: EdgeInsets.all(48), child: Text('Aucun produit disponible', style: TextStyle(color: WajbaColors.grey400, fontFamily: 'Cairo')))))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final p = products[i];
                        if (_categories.length > 1 && _tabCtrl.index > 0) {
                          if (p.category != _categories[_tabCtrl.index]) return const SizedBox.shrink();
                        }
                        return _ProductTile(
                          product: p,
                          cartQuantity: cart.items.where((it) => it.productId == p.id).fold(0, (s, it) => s + it.quantity),
                          onAdd: () => _addToCart(p, restaurant),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          ),

          // ── Cart FAB ──────────────────────────────────
          if (cartCount > 0 && cart.restaurantId == widget.restaurantId)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.cart),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: WajbaColors.primary, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: WajbaColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Cairo')),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Voir mon panier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Cairo'))),
                      Text(ref.watch(cartProvider).totalLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Cairo')),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addToCart(ProductModel product, RestaurantModel restaurant) {
    final cart = ref.read(cartProvider);
    if (cart.restaurantId != null && cart.restaurantId != widget.restaurantId) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nouveau restaurant', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          content: const Text('Votre panier sera vidé pour commander dans ce restaurant. Continuer ?', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(cartProvider.notifier).clearForNewRestaurant();
                ref.read(cartProvider.notifier).addItem(product);
                _showAddedSnack(product.name);
              },
              child: const Text('Continuer', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      );
    } else {
      ref.read(cartProvider.notifier).addItem(product);
      _showAddedSnack(product.name);
    }
  }

  void _showAddedSnack(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$name ajouté au panier', style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: WajbaColors.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _divider() => Container(width: 1, height: 28, color: WajbaColors.grey100, margin: const EdgeInsets.symmetric(horizontal: 8));
}

class _InfoTile extends StatelessWidget {
  final String icon, value, label;
  const _InfoTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
        Text(label, style: const TextStyle(fontSize: 10, color: WajbaColors.grey400, fontFamily: 'Cairo')),
      ],
    ),
  );
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final int cartQuantity;
  final VoidCallback onAdd;

  const _ProductTile({required this.product, required this.cartQuantity, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WajbaColors.grey100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: WajbaColors.primaryBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(product.badge!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: WajbaColors.primary, fontFamily: 'Cairo')),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                if (product.description != null) ...[
                  const SizedBox(height: 4),
                  Text(product.description!, style: const TextStyle(fontSize: 12, color: WajbaColors.grey500, height: 1.4, fontFamily: 'Cairo'), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 10),
                Text(product.priceLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: WajbaColors.primary, fontFamily: 'Cairo')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Photo + Add
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.photo != null
                    ? CachedNetworkImage(imageUrl: product.photo!, width: 90, height: 90, fit: BoxFit.cover)
                    : Container(
                        width: 90, height: 90,
                        color: WajbaColors.grey50,
                        child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 36))),
                      ),
              ),
              Positioned(
                bottom: -12, right: -4,
                child: GestureDetector(
                  onTap: product.isAvailable ? onAdd : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: product.isAvailable ? WajbaColors.primary : WajbaColors.grey300,
                      shape: BoxShape.circle,
                      boxShadow: product.isAvailable ? [BoxShadow(color: WajbaColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Center(
                      child: cartQuantity > 0
                          ? Text('$cartQuantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))
                          : const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  const _TabBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _tabBar,
          Container(height: 0.5, color: WajbaColors.grey100),
        ],
      ),
    );
  }

  @override double get maxExtent => 50;
  @override double get minExtent => 50;
  @override bool shouldRebuild(covariant _TabBarDelegate old) => false;
}
