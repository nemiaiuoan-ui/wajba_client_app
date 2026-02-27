import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  String _payment    = 'cash';
  bool   _isLoading  = false;

  final _payments = const [
    {'id': 'cash',      'label': '💵 Espèces à la livraison', 'desc': 'Payez en main propre'},
    {'id': 'ccp',       'label': '💳 CCP / BaridiMob',        'desc': 'Virement postal'},
    {'id': 'dahabiya',  'label': '💳 Dahabia',                'desc': 'Carte Algérie Poste'},
  ];

  @override
  void initState() {
    super.initState();
    final addr = context.read<AuthProvider>().user?.address ?? '';
    _addressCtrl.text = addr;
  }

  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final auth  = context.read<AuthProvider>();
    final order = context.read<OrderProvider>();

    // Livraison: on récupère depuis le restaurant selected
    const deliveryFee = 200; // valeur par défaut
    final total = cart.total(deliveryFee);

    return Scaffold(
      appBar: AppBar(title: const Text('Finaliser la commande')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Adresse ──────────────────────────────────────────
          _Section('📍 Adresse de livraison', child: TextField(
            controller: _addressCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Entrez votre adresse complète...',
            ),
          )),
          const SizedBox(height: 20),

          // ── Paiement ─────────────────────────────────────────
          _Section('💳 Mode de paiement',
            child: Column(
              children: _payments.map((m) => RadioListTile<String>(
                value: m['id']!,
                groupValue: _payment,
                onChanged: (v) => setState(() => _payment = v!),
                activeColor: WajbaColors.primary,
                title: Text(m['label']!,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(m['desc']!,
                  style: const TextStyle(fontSize: 12, color: WajbaColors.grey600)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _payment == m['id'] ? WajbaColors.primary : WajbaColors.grey200,
                  ),
                ),
                tileColor: _payment == m['id']
                    ? WajbaColors.primary.withOpacity(0.05)
                    : WajbaColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Récapitulatif ────────────────────────────────────
          _Section('🧾 Récapitulatif',
            child: Column(children: [
              ...cart.items.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${i.product.name} x${i.quantity}',
                      style: const TextStyle(color: WajbaColors.grey600)),
                    Text('${i.total} DA',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
              const Divider(height: 24),
              _SummaryRow('Sous-total', cart.subtotal),
              _SummaryRow('Livraison',  deliveryFee),
              const Divider(height: 16),
              _SummaryRow('Total', total, isTotal: true),
            ]),
          ),
          const SizedBox(height: 32),

          // ── Bouton commander ─────────────────────────────────
          WajbaButton(
            label: 'Confirmer la commande • $total DA',
            icon: Icons.check_circle,
            isLoading: _isLoading,
            onTap: () async {
              if (_addressCtrl.text.trim().isEmpty) {
                showSnack(context, 'Entrez votre adresse', isError: true);
                return;
              }
              setState(() => _isLoading = true);
              final orderId = await order.placeOrder(
                userId:         auth.uid,
                restaurantId:   cart.restaurantId,
                restaurantName: cart.restaurantName,
                items:          cart.items,
                address:        _addressCtrl.text.trim(),
                paymentMethod:  _payment,
                deliveryFee:    deliveryFee,
              );
              setState(() => _isLoading = false);
              if (!mounted) return;
              if (orderId != null) {
                cart.clearCart();
                context.go('/order-tracking/$orderId');
              } else {
                showSnack(context, 'Erreur commande, réessayez', isError: true);
              }
            },
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  @override
  void dispose() { _addressCtrl.dispose(); super.dispose(); }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section(this.title, {required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: WajbaColors.dark)),
      const SizedBox(height: 12),
      child,
    ],
  );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int    amount;
  final bool   isTotal;
  const _SummaryRow(this.label, this.amount, {this.isTotal = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
        fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        fontSize:   isTotal ? 16 : 14,
        color: isTotal ? WajbaColors.dark : WajbaColors.grey600,
      )),
      Text('$amount DA', style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize:   isTotal ? 18 : 14,
        color: isTotal ? WajbaColors.primary : WajbaColors.dark,
      )),
    ]),
  );
}
