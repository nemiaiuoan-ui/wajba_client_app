import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
// ─── PHONE AUTH SCREEN ────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneCtrl = TextEditingController(text: '+213');
  final _formKey   = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPaddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text('🍽️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Votre numéro\nde téléphone',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                                   color: WajbaColors.dark)),
                const SizedBox(height: 8),
                const Text('Nous vous enverrons un SMS de vérification',
                  style: TextStyle(color: WajbaColors.grey600, fontSize: 15)),
                const SizedBox(height: 32),

                // Champ téléphone
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone, color: WajbaColors.primary),
                    hintText: '+213 6XX XX XX XX',
                    labelText: 'Numéro de téléphone',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 12) {
                      return 'Entrez un numéro valide (+213...)';
                    }
                    return null;
                  },
                ),

                if (auth.error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WajbaColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(auth.error,
                      style: const TextStyle(color: WajbaColors.error, fontSize: 13)),
                  ),
                ],

                const Spacer(),
                WajbaButton(
                  label: 'Envoyer le code SMS',
                  icon: Icons.sms,
                  isLoading: auth.isLoading,
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;
                    auth.clearError();
                    final phone = _phoneCtrl.text.trim().replaceAll(' ', '');
                    final ok = await auth.sendOtp(phone);
                    if (ok && mounted) {
                      context.push('/auth/otp', extra: phone);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }
}
