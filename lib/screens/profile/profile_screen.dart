import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(children: [

          // ── Avatar + Nom ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(kPaddingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [WajbaColors.primaryDark, WajbaColors.primary],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(kRadiusL),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: WajbaColors.white.withOpacity(0.2),
                child: Text(
                  (user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?'),
                  style: const TextStyle(color: WajbaColors.white,
                                         fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.name ?? 'Utilisateur',
                    style: const TextStyle(color: WajbaColors.white,
                                           fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              )),
              IconButton(
                onPressed: () => context.push('/edit-profile'),
                icon: const Icon(Icons.edit, color: WajbaColors.white),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Menu ─────────────────────────────────────────────
          _MenuItem(
            Icons.location_on_outlined, 'Adresse de livraison',
            subtitle: user?.address.isNotEmpty == true ? user!.address : 'Non définie',
            onTap: () => context.push('/edit-profile'),
          ),
          _MenuItem(
            Icons.email_outlined, 'Email',
            subtitle: user?.email.isNotEmpty == true ? user!.email : 'Non défini',
            onTap: () => context.push('/edit-profile'),
          ),
          _MenuItem(
            Icons.receipt_long_outlined, 'Mes commandes',
            onTap: () => context.go('/orders'),
          ),
          _MenuItem(
            Icons.help_outline, 'Aide et support',
            onTap: () {},
          ),
          _MenuItem(
            Icons.info_outline, 'À propos de Wajba',
            onTap: () {},
          ),
          const SizedBox(height: 20),

          // ── Déconnexion ───────────────────────────────────────
          WajbaButton(
            label: 'Se déconnecter',
            icon: Icons.logout,
            color: WajbaColors.grey800,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vous déconnecter ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false),
                               child: const Text('Annuler')),
                    TextButton(onPressed: () => Navigator.pop(context, true),
                               child: const Text('Oui',
                                 style: TextStyle(color: WajbaColors.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().signOut();
              }
            },
          ),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, {this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: WajbaColors.white,
        borderRadius: BorderRadius.circular(kRadiusM),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: WajbaColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: WajbaColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500,
                                                color: WajbaColors.dark)),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(
                color: WajbaColors.grey600, fontSize: 12), maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        )),
        const Icon(Icons.chevron_right, color: WajbaColors.grey400),
      ]),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────
// EDIT PROFILE SCREEN
// ──────────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nameCtrl    = TextEditingController();
  late final _emailCtrl   = TextEditingController();
  late final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text    = user.name;
      _emailCtrl.text   = user.email;
      _addressCtrl.text = user.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(children: [
          _field(_nameCtrl,    'Nom complet',   Icons.person_outline),
          const SizedBox(height: 16),
          _field(_emailCtrl,   'Email',          Icons.email_outlined,
                 type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _field(_addressCtrl, 'Adresse',        Icons.location_on_outlined,
                 maxLines: 2),
          const SizedBox(height: 32),
          WajbaButton(
            label: 'Enregistrer',
            isLoading: auth.isLoading,
            onTap: () async {
              final updated = auth.user!.copyWith(
                name:    _nameCtrl.text.trim(),
                email:   _emailCtrl.text.trim(),
                address: _addressCtrl.text.trim(),
              );
              final ok = await auth.updateProfile(updated);
              if (ok && mounted) {
                showSnack(context, 'Profil mis à jour !');
                context.pop();
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) =>
    TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
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
