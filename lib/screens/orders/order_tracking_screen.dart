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

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.read<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de commande'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: StreamBuilder<Order>(
        stream: orderProv.trackOrder(orderId),
        builder: (context, snap) {
          if (snap.hasError) {
            return const EmptyState(
              icon: Icons.error_outline, title: 'Erreur de suivi');
          }
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: WajbaColors.primary));
          }

          final order = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kPaddingM),
            child: Column(children: [

              // ── Statut animé ──────────────────────────────────
              _StatusAnimation(status: order.status),
              const SizedBox(height: 24),

              // ── Timeline ─────────────────────────────────────
              _Timeline(status: order.status),
              const SizedBox(height: 24),

              // ── Temps estimé ─────────────────────────────────
              if (order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled)
                Container(
                  padding: const EdgeInsets.all(kPaddingM),
                  decoration: BoxDecoration(
                    color: WajbaColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(kRadiusM),
                  ),
                  child: Row(children: [
                    const Icon(Icons.access_time, color: WajbaColors.primary),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Temps estimé',
                        style: TextStyle(color: WajbaColors.grey600, fontSize: 12)),
                      Text('${order.estimatedTime} minutes',
                        style: const TextStyle(
                          color: WajbaColors.primary,
                          fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                  ]),
                ),
              const SizedBox(height: 24),

              // ── Détails commande ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(kPaddingM),
                decoration: BoxDecoration(
                  color: WajbaColors.white,
                  borderRadius: BorderRadius.circular(kRadiusM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commande #${orderId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold,
                                             color: WajbaColors.grey600)),
                    const SizedBox(height: 8),
                    Text(order.restaurantName,
                      style: const TextStyle(fontSize: 16,
                                             fontWeight: FontWeight.bold,
                                             color: WajbaColors.dark)),
                    const Divider(height: 20),
                    ...order.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${i['name']} x${i['quantity']}',
                            style: const TextStyle(color: WajbaColors.grey600)),
                          Text('${(i['price'] as int) * (i['quantity'] as int)} DA'),
                        ],
                      ),
                    )),
                    const Divider(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${order.total} DA',
                        style: const TextStyle(color: WajbaColors.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: WajbaColors.grey400),
                      const SizedBox(width: 4),
                      Expanded(child: Text(order.address,
                        style: const TextStyle(color: WajbaColors.grey600, fontSize: 12))),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Commande livrée ───────────────────────────────
              if (order.status == OrderStatus.delivered) ...[
                const Icon(Icons.check_circle, size: 64, color: WajbaColors.success),
                const SizedBox(height: 12),
                const Text('Commande livrée !',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                   color: WajbaColors.success)),
                const SizedBox(height: 8),
                const Text('Bon appétit ! 🍽️',
                  style: TextStyle(color: WajbaColors.grey600, fontSize: 16)),
                const SizedBox(height: 24),
                WajbaButton(
                  label: 'Retour à l\'accueil',
                  onTap: () => context.go('/home'),
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}

// ─── Animations statut ────────────────────────────────────────────
class _StatusAnimation extends StatelessWidget {
  final OrderStatus status;
  const _StatusAnimation({required this.status});

  String get _emoji {
    switch (status) {
      case OrderStatus.pending:    return '⏳';
      case OrderStatus.confirmed:  return '✅';
      case OrderStatus.preparing:  return '👨‍🍳';
      case OrderStatus.ready:      return '📦';
      case OrderStatus.delivering: return '🛵';
      case OrderStatus.delivered:  return '🎉';
      case OrderStatus.cancelled:  return '❌';
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(_emoji, style: const TextStyle(fontSize: 64)),
    const SizedBox(height: 12),
    Text(status.label,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                             color: WajbaColors.dark)),
  ]);
}

// ─── Timeline progression ─────────────────────────────────────────
class _Timeline extends StatelessWidget {
  final OrderStatus status;
  const _Timeline({required this.status});

  static const _steps = [
    OrderStatus.pending, OrderStatus.confirmed, OrderStatus.preparing,
    OrderStatus.delivering, OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(status);

    return Column(children: List.generate(_steps.length, (i) {
      final done    = i <= currentIdx;
      final current = i == currentIdx;

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icône
        Column(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? WajbaColors.primary : WajbaColors.grey200,
              border: current ? Border.all(color: WajbaColors.primary, width: 3) : null,
            ),
            child: done
                ? const Icon(Icons.check, size: 14, color: WajbaColors.white)
                : null,
          ),
          if (i < _steps.length - 1)
            Container(
              width: 2, height: 36,
              color: done ? WajbaColors.primary : WajbaColors.grey200,
            ),
        ]),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _steps[i].label,
            style: TextStyle(
              fontWeight: current ? FontWeight.bold : FontWeight.normal,
              color: done ? WajbaColors.dark : WajbaColors.grey400,
              fontSize: 14,
            ),
          ),
        ),
      ]);
    }));
  }
}
