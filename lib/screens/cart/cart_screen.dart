import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
// ══════════════════════════════════════════════════════════════════
// CART SCREEN
// ══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon panier'),
        actions: [
          if (cart.itemCount > 0)
            TextButton(
              onPressed: cart.clearCart,
              child: const Text('Vider', style: TextStyle(color: WajbaColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Panier vide',
              subtitle: 'Ajoutez des plats depuis un restaurant',
            )
          : Column(
              children: [
                // Restaurant nom
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: kPaddingM, vertical: kPaddingS),
                  color: WajbaColors.primary.withOpacity(0.08),
                  child: Row(children: [
                    const Icon(Icons.restaurant, size: 16, color: WajbaColors.primary),
                    const SizedBox(width: 8),
                    Text(cart.restaurantName,
                      style: const TextStyle(
                          color: WajbaColors.primary, fontWeight: FontWeight.w600)),
                  ]),
                ),

                // Liste articles
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(kPaddingM),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => _CartItemRow(item: cart.items[i]),
                  ),
                ),

                // Résumé
                Container(
                  padding: const EdgeInsets.all(kPaddingM),
                  decoration: BoxDecoration(
                    color: WajbaColors.white,
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12, offset: const Offset(0, -4),
                    )],
                  ),
                  child: Column(
                    children: [
                      _Row('Sous-total', '${cart.subtotal} DA'),
                      const SizedBox(height: 16),
                      WajbaButton(
                        label: 'Commander • ${cart.subtotal} DA',
                        icon: Icons.arrow_forward,
                        onTap: () => context.push('/checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: WajbaColors.white,
        borderRadius: BorderRadius.circular(kRadiusM),
      ),
      child: Row(children: [
        WajbaImage(item.product.imageUrl, width: 60, height: 60,
                   radius: BorderRadius.circular(8)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.product.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text('${item.product.price} DA',
              style: const TextStyle(color: WajbaColors.grey600, fontSize: 13)),
          ],
        )),
        // Quantity controls
        Row(children: [
          _Btn(Icons.remove, onTap: () => cart.removeItem(item.product.id)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _Btn(Icons.add, filled: true,
               onTap: () => cart.addItem(item.product,
                   cart.restaurantId, cart.restaurantName)),
        ]),
        const SizedBox(width: 8),
        Text('${item.total} DA',
          style: const TextStyle(color: WajbaColors.primary,
                                  fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _Btn(this.icon, {required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: filled ? WajbaColors.primary : WajbaColors.white,
        border: Border.all(color: WajbaColors.primary),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 14,
        color: filled ? WajbaColors.white : WajbaColors.primary),
    ),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
        color: bold ? WajbaColors.dark : WajbaColors.grey600,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      )),
      Text(value, style: TextStyle(
        color: bold ? WajbaColors.primary : WajbaColors.dark,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      )),
    ]),
  );
}
