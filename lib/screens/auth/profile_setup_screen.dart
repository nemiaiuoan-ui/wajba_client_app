import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
// ══════════════════════════════════════════════════════════════════
// PROFILE SETUP SCREEN
// ══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Votre profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kPaddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                const Text('Bienvenue !',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                                   color: WajbaColors.dark)),
                const SizedBox(height: 8),
                const Text('Complétez votre profil pour continuer',
                  style: TextStyle(color: WajbaColors.grey600)),
                const SizedBox(height: 32),

                _field(controller: _nameCtrl,    label: 'Nom complet *',
                       icon: Icons.person_outline,
                       validator: (v) => v!.isEmpty ? 'Champ requis' : null),
                const SizedBox(height: 16),
                _field(controller: _emailCtrl,   label: 'Email',
                       icon: Icons.email_outlined,
                       keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _field(controller: _addressCtrl, label: 'Adresse de livraison',
                       icon: Icons.location_on_outlined, maxLines: 2),
                const SizedBox(height: 32),

                if (auth.error.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: WajbaColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: Text(auth.error,
                      style: const TextStyle(color: WajbaColors.error)),
                  ),
                  const SizedBox(height: 16),
                ],

                WajbaButton(
                  label: 'Créer mon compte',
                  isLoading: auth.isLoading,
                  onTap: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final ok = await auth.completeProfile(
                      name:    _nameCtrl.text.trim(),
                      email:   _emailCtrl.text.trim(),
                      address: _addressCtrl.text.trim(),
                    );
                    if (ok && mounted) context.go('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: WajbaColors.primary),
    ),
  );

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }
}
