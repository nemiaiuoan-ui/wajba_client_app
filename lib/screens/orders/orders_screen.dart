// ══════════════════════════════════════════════════════════════════
// ORDERS SCREEN
// ══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().uid;
      context.read<OrderProvider>().loadOrders(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator(color: WajbaColors.primary))
          : prov.orders.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Aucune commande',
                  subtitle: 'Passez votre première commande maintenant !',
                  buttonLabel: 'Explorer',
                  onButton: () => context.go('/home'),
                )
              : RefreshIndicator(
                  color: WajbaColors.primary,
                  onRefresh: () => prov.loadOrders(
                      context.read<AuthProvider>().uid),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(kPaddingM),
                    itemCount: prov.orders.length,
                    itemBuilder: (_, i) => _OrderCard(order: prov.orders[i]),
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy • HH:mm', 'fr');

    return GestureDetector(
      onTap: () {
        if (order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled) {
          context.push('/order-tracking/${order.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(kPaddingM),
        decoration: BoxDecoration(
          color: WajbaColors.white,
          borderRadius: BorderRadius.circular(kRadiusM),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(order.restaurantName,
              style: const TextStyle(fontWeight: FontWeight.bold,
                                     fontSize: 15, color: WajbaColors.dark)),
            OrderStatusBadge(order.status.name),
          ]),
          const SizedBox(height: 6),
          Text(fmt.format(order.createdAt),
            style: const TextStyle(color: WajbaColors.grey600, fontSize: 12)),
          const SizedBox(height: 8),
          Text('${order.items.length} article(s)',
            style: const TextStyle(color: WajbaColors.grey600, fontSize: 13)),
          const Divider(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total: ${order.total} DA',
              style: const TextStyle(fontWeight: FontWeight.bold,
                                     color: WajbaColors.primary, fontSize: 15)),
            if (order.status != OrderStatus.delivered &&
                order.status != OrderStatus.cancelled)
              const Row(children: [
                Text('Suivre ', style: TextStyle(
                  color: WajbaColors.primary, fontSize: 13,
                  fontWeight: FontWeight.w500)),
                Icon(Icons.arrow_forward_ios, size: 12, color: WajbaColors.primary),
              ]),
          ]),
        ]),
      ),
    );
  }
}
