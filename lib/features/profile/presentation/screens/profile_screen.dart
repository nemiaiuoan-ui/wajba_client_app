import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final user = userAsync.value;

    return Scaffold(
      backgroundColor: WajbaColors.bgSecondary,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile card ─────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Utilisateur', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Cairo')),
                      const SizedBox(height: 4),
                      Text(user?.phone ?? '', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85), fontFamily: 'Cairo')),
                      if (user?.email != null) Text(user!.email!, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push(AppRoutes.editProfile),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Stats row ────────────────────────────
          Row(
            children: [
              _StatCard(emoji: '🛒', value: '12', label: 'Commandes'),
              const SizedBox(width: 10),
              _StatCard(emoji: '⭐', value: '4.9', label: 'Votre note'),
              const SizedBox(width: 10),
              _StatCard(emoji: '💰', value: '18 400', label: 'DZD dépensés'),
            ],
          ),
          const SizedBox(height: 20),

          // ── Menu sections ────────────────────────
          _SectionLabel('Mon compte'),
          _MenuGroup(items: [
            _MenuItem(icon: Icons.shopping_bag_outlined, label: 'Mes commandes', color: WajbaColors.primary, onTap: () => context.push(AppRoutes.orders)),
            _MenuItem(icon: Icons.location_on_outlined, label: 'Mes adresses', color: WajbaColors.info, onTap: () => context.push(AppRoutes.addresses)),
            _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', color: WajbaColors.warning, onTap: () => context.push(AppRoutes.notifications)),
            _MenuItem(icon: Icons.favorite_outline, label: 'Favoris', color: WajbaColors.error, onTap: () {}),
          ]),
          const SizedBox(height: 16),

          _SectionLabel('Préférences'),
          _MenuGroup(items: [
            _MenuItem(icon: Icons.language_outlined, label: 'Langue', color: WajbaColors.purple, value: 'Français', onTap: () {}),
            _MenuItem(icon: Icons.dark_mode_outlined, label: 'Mode sombre', color: WajbaColors.grey700, onTap: () {}),
          ]),
          const SizedBox(height: 16),

          _SectionLabel('Support'),
          _MenuGroup(items: [
            _MenuItem(icon: Icons.help_outline_rounded, label: 'Aide & FAQ', color: WajbaColors.info, onTap: () {}),
            _MenuItem(icon: Icons.support_agent_outlined, label: 'Contacter le support', color: WajbaColors.success, onTap: () => context.push(AppRoutes.support)),
            _MenuItem(icon: Icons.policy_outlined, label: 'Politique de confidentialité', color: WajbaColors.grey500, onTap: () {}),
            _MenuItem(icon: Icons.info_outline, label: 'À propos', color: WajbaColors.grey500, value: 'v1.0.0', onTap: () {}),
          ]),
          const SizedBox(height: 16),

          // ── Logout ───────────────────────────────
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: WajbaColors.errorBg, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout_rounded, color: WajbaColors.error, size: 18),
              ),
              title: const Text('Déconnexion', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.error, fontFamily: 'Cairo')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: WajbaColors.grey300),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
          const SizedBox(height: 32),

          // WAJBA version tag
          Center(
            child: Column(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 28)),
                const Text('WAJBA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: WajbaColors.primary, letterSpacing: 3, fontFamily: 'Cairo')),
                const Text('Livraison alimentaire — Annaba', style: TextStyle(fontSize: 11, color: WajbaColors.grey400, fontFamily: 'Cairo')),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: WajbaColors.error),
            child: const Text('Déconnexion', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  const _StatCard({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: WajbaColors.grey900, fontFamily: 'Cairo')),
          Text(label, style: const TextStyle(fontSize: 10, color: WajbaColors.grey400, fontFamily: 'Cairo')),
        ],
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WajbaColors.grey400, letterSpacing: 0.5, fontFamily: 'Cairo')),
  );
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
    child: Column(
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        return Column(
          children: [
            ListTile(
              dense: true,
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              title: Text(item.label, style: const TextStyle(fontSize: 14, fontFamily: 'Cairo', fontWeight: FontWeight.w500)),
              trailing: item.value != null
                  ? Text(item.value!, style: const TextStyle(fontSize: 12, color: WajbaColors.grey400, fontFamily: 'Cairo'))
                  : const Icon(Icons.arrow_forward_ios, size: 13, color: WajbaColors.grey300),
              onTap: item.onTap,
            ),
            if (i < items.length - 1) const Divider(height: 0, indent: 64),
          ],
        );
      }).toList(),
    ),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? value;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, required this.color, this.value, this.onTap});
}
