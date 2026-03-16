import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';

// ═══════════════════════════════════════════════
// CART SCREEN
// ═══════════════════════════════════════════════
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Mon panier')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text('Votre panier est vide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
              const SizedBox(height: 8),
              const Text('Ajoutez des plats pour continuer', style: TextStyle(fontSize: 14, color: WajbaColors.grey500, fontFamily: 'Cairo')),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Explorer les restaurants'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WajbaColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Mon panier'),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _confirmClear(context, ref),
            child: const Text('Vider', style: TextStyle(color: WajbaColors.error, fontFamily: 'Cairo')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Restaurant name
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const Text('🍽️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(cart.restaurantName ?? 'Restaurant', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Items
                ...cart.items.map((item) => _CartItemTile(item: item, ref: ref)),

                const SizedBox(height: 16),

                // Promo code
                _PromoField(ref: ref),
                const SizedBox(height: 16),

                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      _SummaryRow('Sous-total', '${cart.subtotal.toInt()} DZD'),
                      const SizedBox(height: 8),
                      _SummaryRow('Livraison', cart.deliveryFee == 0 ? 'Gratuit 🎉' : '${cart.deliveryFee.toInt()} DZD'),
                      if (cart.discount > 0) ...[
                        const SizedBox(height: 8),
                        _SummaryRow('Réduction (${cart.promoCode})', '-${cart.discount.toInt()} DZD', color: WajbaColors.success),
                      ],
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                      _SummaryRow('Total', cart.totalLabel, isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Checkout button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.checkout),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Confirmer la commande', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                      const SizedBox(width: 8),
                      Text('· ${cart.totalLabel}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider le panier', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('Voulez-vous supprimer tous les articles ?', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () { ref.read(cartProvider.notifier).clear(); Navigator.pop(context); context.pop(); },
            style: ElevatedButton.styleFrom(backgroundColor: WajbaColors.error),
            child: const Text('Oui, vider', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final WidgetRef ref;
  const _CartItemTile({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.photo != null
                ? CachedNetworkImage(imageUrl: item.photo!, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: WajbaColors.grey100, child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 26)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo'), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${item.unitPrice.toInt()} DZD', style: const TextStyle(fontSize: 13, color: WajbaColors.grey500, fontFamily: 'Cairo')),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              _QtyButton(icon: Icons.remove, onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity - 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ),
              _QtyButton(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.productId, item.quantity + 1), primary: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  const _QtyButton({required this.icon, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: primary ? WajbaColors.primary : WajbaColors.grey100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: primary ? Colors.white : WajbaColors.grey700),
    ),
  );
}

class _PromoField extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _PromoField({required this.ref});
  @override
  ConsumerState<_PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends ConsumerState<_PromoField> {
  final _ctrl = TextEditingController();
  bool _applied = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _apply() {
    if (_ctrl.text.trim().toUpperCase() == 'WAJBA10') {
      final subtotal = ref.read(cartProvider).subtotal;
      ref.read(cartProvider.notifier).applyPromo('WAJBA10', subtotal * 0.10);
      setState(() => _applied = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code promo invalide'), backgroundColor: WajbaColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_applied) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: WajbaColors.successBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: WajbaColors.success.withOpacity(0.3))),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: WajbaColors.success, size: 20),
            const SizedBox(width: 10),
            const Text('Code WAJBA10 appliqué ! -10%', style: TextStyle(color: WajbaColors.success, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
            const Spacer(),
            GestureDetector(
              onTap: () { ref.read(cartProvider.notifier).removePromo(); setState(() => _applied = false); _ctrl.clear(); },
              child: const Icon(Icons.close, color: WajbaColors.success, size: 18),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: WajbaColors.grey200)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: '🏷️  Code promo',
                hintStyle: TextStyle(fontFamily: 'Cairo'),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _ctrl.text.isNotEmpty ? _apply : null,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Appliquer', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  final Color? color;
  const _SummaryRow(this.label, this.value, {this.isTotal = false, this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: TextStyle(fontSize: isTotal ? 15 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400, color: isTotal ? WajbaColors.grey900 : WajbaColors.grey600, fontFamily: 'Cairo')),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600, color: color ?? (isTotal ? WajbaColors.primary : WajbaColors.grey800), fontFamily: 'Cairo')),
    ],
  );
}

// ═══════════════════════════════════════════════
// CHECKOUT SCREEN
// ═══════════════════════════════════════════════
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'cash';
  bool _loading = false;
  AddressModel? _selectedAddress;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final address = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: WajbaColors.bgSecondary,
      appBar: AppBar(title: const Text('Confirmation'), backgroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Delivery Address ──────────────────
                _Section(
                  title: '📍 Adresse de livraison',
                  trailing: TextButton(
                    onPressed: () => context.push(AppRoutes.addresses),
                    child: const Text('Changer', style: TextStyle(color: WajbaColors.primary, fontFamily: 'Cairo')),
                  ),
                  child: address == null
                      ? GestureDetector(
                          onTap: () => context.push(AppRoutes.addAddress),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: WajbaColors.grey200, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_location_alt_outlined, color: WajbaColors.primary),
                                SizedBox(width: 10),
                                Text('Ajouter une adresse', style: TextStyle(color: WajbaColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: WajbaColors.primaryBg, borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text(address.labelIcon, style: const TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(address.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                                  Text(address.fullAddress, style: const TextStyle(fontSize: 12, color: WajbaColors.grey500, fontFamily: 'Cairo'), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 14),

                // ── Payment Method ────────────────────
                _Section(
                  title: '💳 Mode de paiement',
                  child: Column(
                    children: [
                      _PaymentOption(value: 'cash', current: _paymentMethod, icon: '💵', label: 'Paiement à la livraison', subtitle: 'Payez en espèces au livreur', onChanged: (v) => setState(() => _paymentMethod = v)),
                      const SizedBox(height: 8),
                      _PaymentOption(value: 'cib', current: _paymentMethod, icon: '💳', label: 'Carte CIB/Dahabia', subtitle: 'Bientôt disponible', onChanged: null, disabled: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Order Summary ─────────────────────
                _Section(
                  title: '🧾 Récapitulatif',
                  child: Column(
                    children: [
                      ...cart.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text('${item.quantity}×', style: const TextStyle(fontSize: 13, color: WajbaColors.grey400, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13, color: WajbaColors.grey800, fontFamily: 'Cairo'), overflow: TextOverflow.ellipsis)),
                            Text('${item.totalPrice.toInt()} DZD', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WajbaColors.grey800, fontFamily: 'Cairo')),
                          ],
                        ),
                      )),
                      const Divider(height: 20),
                      _SummaryRow('Sous-total', '${cart.subtotal.toInt()} DZD'),
                      const SizedBox(height: 6),
                      _SummaryRow('Livraison', cart.deliveryFee == 0 ? 'Gratuit 🎉' : '${cart.deliveryFee.toInt()} DZD'),
                      if (cart.discount > 0) ...[const SizedBox(height: 6), _SummaryRow('Réduction', '-${cart.discount.toInt()} DZD', color: WajbaColors.success)],
                      const Divider(height: 20),
                      _SummaryRow('Total à payer', cart.totalLabel, isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Place Order Button ────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: address == null || _loading ? null : () => _placeOrder(context, ref, cart, address),
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Commander maintenant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                            const SizedBox(width: 8),
                            Text('· ${cart.totalLabel}', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, WidgetRef ref, CartModel cart, AddressModel address) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // Simule API
    if (mounted) {
      ref.read(cartProvider.notifier).clear();
      context.go('/order-confirm/WJB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _Section({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _PaymentOption extends StatelessWidget {
  final String value, current, icon, label, subtitle;
  final ValueChanged<String>? onChanged;
  final bool disabled;

  const _PaymentOption({required this.value, required this.current, required this.icon, required this.label, required this.subtitle, required this.onChanged, this.disabled = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: disabled ? null : () => onChanged?.call(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: current == value && !disabled ? WajbaColors.primaryBg : WajbaColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: current == value && !disabled ? WajbaColors.primary : WajbaColors.grey200, width: current == value ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: disabled ? WajbaColors.grey400 : WajbaColors.grey900, fontFamily: 'Cairo')),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: WajbaColors.grey400, fontFamily: 'Cairo')),
              ],
            ),
          ),
          if (!disabled)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current == value ? WajbaColors.primary : Colors.transparent,
                border: Border.all(color: current == value ? WajbaColors.primary : WajbaColors.grey300, width: 2),
              ),
              child: current == value ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
            ),
        ],
      ),
    ),
  );
}
