import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';

// ═══════════════════════════════════════════════
// ORDERS LIST SCREEN
// ═══════════════════════════════════════════════
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock orders for demo
    final activeOrders = _mockOrders.where((o) => o.status.isActive).toList();
    final pastOrders = _mockOrders.where((o) => !o.status.isActive).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: WajbaColors.bgSecondary,
        appBar: AppBar(
          title: const Text('Mes commandes'),
          backgroundColor: Colors.white,
          bottom: TabBar(
            labelColor: WajbaColors.primary,
            unselectedLabelColor: WajbaColors.grey400,
            indicatorColor: WajbaColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
            tabs: [
              Tab(text: 'En cours (${activeOrders.length})'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active orders
            activeOrders.isEmpty
                ? _EmptyOrders(msg: 'Aucune commande en cours')
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(order: activeOrders[i], isActive: true),
                  ),
            // Past orders
            pastOrders.isEmpty
                ? _EmptyOrders(msg: 'Aucun historique')
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pastOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(order: pastOrders[i], isActive: false),
                  ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  const _OrderCard({required this.order, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: WajbaColors.primaryBg, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.restaurantName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                      Text(timeago.format(order.createdAt, locale: 'fr'), style: const TextStyle(fontSize: 12, color: WajbaColors.grey400, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 20),
            Text(
              order.items.map((i) => '${i.quantity}× ${i.name}').join(', '),
              style: const TextStyle(fontSize: 13, color: WajbaColors.grey600, fontFamily: 'Cairo'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(order.totalLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: WajbaColors.primary, fontFamily: 'Cairo')),
                const Spacer(),
                if (isActive && order.canTrack)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/tracking/${order.id}'),
                    icon: const Icon(Icons.location_on, size: 14),
                    label: const Text('Suivre', style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  )
                else if (order.canRate)
                  OutlinedButton.icon(
                    onPressed: () => _showRatingDialog(context, order),
                    icon: const Icon(Icons.star_outline, size: 14),
                    label: const Text('Évaluer', style: TextStyle(fontSize: 12, fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  )
                else if (!order.status.isActive && !order.canRate)
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Commander à nouveau', style: TextStyle(fontSize: 11, fontFamily: 'Cairo')),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, OrderModel order) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Évaluer la commande', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(order.restaurantName, style: const TextStyle(fontFamily: 'Cairo', color: WajbaColors.grey500)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => rating = i + 1),
                  child: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: WajbaColors.star, size: 40),
                )),
              ),
              const SizedBox(height: 16),
              Text(['', 'Mauvais', 'Passable', 'Correct', 'Bien', 'Excellent'][rating], style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16, color: WajbaColors.primary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merci pour votre avis ! ⭐'), backgroundColor: WajbaColors.success)); },
              child: const Text('Envoyer', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.delivered: return WajbaColors.success;
      case OrderStatus.cancelled: return WajbaColors.error;
      case OrderStatus.picked_up: return WajbaColors.primary;
      default: return WajbaColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _color.withOpacity(0.3)),
    ),
    child: Text(
      '${status.emoji} ${status.label}',
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _color, fontFamily: 'Cairo'),
    ),
  );
}

class _EmptyOrders extends StatelessWidget {
  final String msg;
  const _EmptyOrders({required this.msg});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📋', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(msg, style: const TextStyle(fontSize: 16, color: WajbaColors.grey500, fontFamily: 'Cairo')),
      ],
    ),
  );
}

// ─── Mock data for display ─────────────────────
final _addr = AddressModel(id: 'a1', label: 'Maison', fullAddress: 'Cité 5 Juillet, Annaba', commune: 'Annaba Centre', lat: 36.9065, lng: 7.7335);
final _mockOrders = [
  OrderModel(
    id: 'wjb-20240301', restaurantId: 'r1', restaurantName: 'Chez Fatima',
    items: [
      CartItemModel(productId: 'p1', restaurantId: 'r1', restaurantName: 'Chez Fatima', name: 'Couscous Traditionnel', basePrice: 850, quantity: 2),
      CartItemModel(productId: 'p5', restaurantId: 'r1', restaurantName: 'Chez Fatima', name: 'Jus Orange Frais', basePrice: 200, quantity: 2),
    ],
    subtotal: 2100, deliveryFee: 0, total: 2100,
    status: OrderStatus.picked_up,
    deliveryAddress: _addr,
    driverName: 'Karim Bensalem',
    createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
    estimatedMinutes: 10,
    isRated: false,
  ),
  OrderModel(
    id: 'wjb-20240228', restaurantId: 'r2', restaurantName: 'Pizza Royale',
    items: [CartItemModel(productId: 'px', restaurantId: 'r2', restaurantName: 'Pizza Royale', name: 'Pizza Margherita', basePrice: 950, quantity: 1)],
    subtotal: 950, deliveryFee: 150, total: 1100,
    status: OrderStatus.delivered,
    deliveryAddress: _addr,
    createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    isRated: false,
  ),
  OrderModel(
    id: 'wjb-20240225', restaurantId: 'r6', restaurantName: 'Shawarma Express',
    items: [CartItemModel(productId: 'ps', restaurantId: 'r6', restaurantName: 'Shawarma Express', name: 'Shawarma Mixte', basePrice: 450, quantity: 2)],
    subtotal: 900, deliveryFee: 100, discount: 90, total: 910,
    status: OrderStatus.delivered,
    deliveryAddress: _addr,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    isRated: true,
  ),
];
