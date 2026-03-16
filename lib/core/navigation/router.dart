import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';

// ── Screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/search_screen.dart';
import '../../features/restaurant/presentation/screens/restaurant_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/order/presentation/screens/tracking_screen.dart';
import '../../features/order/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// ═══════════════════════════════════════════════
// BOTTOM NAV SHELL
// ═══════════════════════════════════════════════
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    AppRoutes.home,
    '/orders',
    '/cart',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: WajbaColors.grey100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil', isActive: currentIndex == 0, onTap: () { setState(() => _currentIndex = 0); context.go(AppRoutes.home); }),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Commandes', isActive: currentIndex == 1, onTap: () { setState(() => _currentIndex = 1); context.go('/orders'); }),
                _CartNavItem(count: cartCount, isActive: currentIndex == 2, onTap: () { setState(() => _currentIndex = 2); context.go('/cart'); }),
                _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', isActive: currentIndex == 3, onTap: () { setState(() => _currentIndex = 3); context.go('/profile'); }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? WajbaColors.primaryBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(isActive ? activeIcon : icon, color: isActive ? WajbaColors.primary : WajbaColors.grey400, size: 24),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: isActive ? WajbaColors.primary : WajbaColors.grey400, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, fontFamily: 'Cairo')),
          ],
        ),
      ),
    ),
  );
}

class _CartNavItem extends StatelessWidget {
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  const _CartNavItem({required this.count, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? WajbaColors.primaryBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(isActive ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined, color: isActive ? WajbaColors.primary : WajbaColors.grey400, size: 24),
              ),
              if (count > 0)
                Positioned(
                  right: 12, top: 2,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: WajbaColors.primary, shape: BoxShape.circle),
                    child: Center(child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Panier', style: TextStyle(fontSize: 10, color: isActive ? WajbaColors.primary : WajbaColors.grey400, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, fontFamily: 'Cairo')),
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════
// ROUTER
// ═══════════════════════════════════════════════
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Auth guard is handled in SplashScreen
      return null;
    },
    routes: [
      // Splash & Onboarding
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final phone = extra?['phone'] as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // Main shell with bottom nav
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // Full screen routes (no bottom nav)
      GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: '/restaurant/:id',
        builder: (_, state) => RestaurantScreen(restaurantId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: '/order-confirm/:id',
        builder: (_, state) => OrderConfirmScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (_, state) => TrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressesScreen()),
      GoRoute(path: '/addresses/add', builder: (_, __) => const AddAddressScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    ],
  );
});

// ── Simple placeholder screens ─────────────────
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes adresses'), backgroundColor: Colors.white),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📍', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Aucune adresse enregistrée', style: TextStyle(color: WajbaColors.grey500, fontFamily: 'Cairo')),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () => context.push('/addresses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une adresse', style: TextStyle(fontFamily: 'Cairo')),
      ),
    ])),
  );
}

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nouvelle adresse'), backgroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Sélectionnez sur la carte ou entrez votre adresse manuellement', style: TextStyle(color: WajbaColors.grey600, fontFamily: 'Cairo')),
      const SizedBox(height: 20),
      ...['Étiquette (Maison, Bureau...)', 'Wilaya', 'Commune', 'Adresse complète', 'Informations supplémentaires'].map((label) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
      )),
      ElevatedButton(onPressed: () => context.pop(), style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)), child: const Text('Enregistrer', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700))),
    ]),
  );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _NotifTile(emoji: '🛵', title: 'Commande en route!', subtitle: 'Karim est en chemin vers chez vous — ~10 min', time: 'Il y a 5 min', read: false),
      _NotifTile(emoji: '✅', title: 'Commande confirmée', subtitle: 'Chez Fatima a confirmé votre commande', time: 'Il y a 32 min', read: false),
      _NotifTile(emoji: '🎁', title: 'Offre exclusive!', subtitle: 'Utilisez WAJBA10 pour -10% sur votre prochaine commande', time: 'Hier', read: true),
    ]),
  );
}

class _NotifTile extends StatelessWidget {
  final String emoji, title, subtitle, time;
  final bool read;
  const _NotifTile({required this.emoji, required this.title, required this.subtitle, required this.time, required this.read});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: read ? Colors.white : WajbaColors.primaryBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: read ? WajbaColors.grey100 : WajbaColors.primaryLight),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: read ? FontWeight.w500 : FontWeight.w700, fontFamily: 'Cairo')),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: WajbaColors.grey500, fontFamily: 'Cairo')),
          const SizedBox(height: 5),
          Text(time, style: const TextStyle(fontSize: 11, color: WajbaColors.grey400, fontFamily: 'Cairo')),
        ])),
        if (!read) Container(width: 8, height: 8, decoration: const BoxDecoration(color: WajbaColors.primary, shape: BoxShape.circle)),
      ],
    ),
  );
}
