import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';

// ═══════════════════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════════════════
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.5, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final user = ref.read(authProvider).value;
    if (user != null) {
      context.go(AppRoutes.main);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WajbaColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: const Center(
                      child: Text('🍽️', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WAJBA',
                    style: TextStyle(
                      fontSize: 38, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: 4,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'وجبة — Livraison rapide',
                    style: TextStyle(
                      fontSize: 14, color: Colors.white.withOpacity(0.85),
                      fontFamily: 'Cairo', letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// ONBOARDING SCREEN
// ═══════════════════════════════════════════════
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bg;
  const _OnboardingPage({required this.emoji, required this.title, required this.subtitle, required this.bg});
}

const _pages = [
  _OnboardingPage(
    emoji: '🍕',
    title: 'Commandez vos plats préférés',
    subtitle: 'Découvrez les meilleurs restaurants d\'Annaba et commandez en quelques clics',
    bg: Color(0xFFFFF7ED),
  ),
  _OnboardingPage(
    emoji: '🛵',
    title: 'Livraison rapide à votre porte',
    subtitle: 'Nos livreurs vous apportent votre repas chaud en moins de 30 minutes',
    bg: Color(0xFFF0FDF4),
  ),
  _OnboardingPage(
    emoji: '📍',
    title: 'Suivez votre commande en direct',
    subtitle: 'Regardez votre livreur sur la carte en temps réel jusqu\'à votre domicile',
    bg: Color(0xFFEFF6FF),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) {
              final p = _pages[i];
              return Container(
                color: p.bg,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Illustration
                        Container(
                          width: 220, height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: WajbaColors.primary.withOpacity(0.12), blurRadius: 40, spreadRadius: 10)],
                          ),
                          child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 100))),
                        ),
                        const SizedBox(height: 52),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: WajbaColors.grey900, height: 1.3, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: WajbaColors.grey500, height: 1.6, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Bottom
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              color: Colors.white,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _ctrl,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: WajbaColors.primary,
                      dotColor: WajbaColors.grey200,
                      dotHeight: 8, dotWidth: 8, expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_page < _pages.length - 1) ...[
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('Ignorer', style: TextStyle(color: WajbaColors.grey400, fontFamily: 'Cairo')),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _ctrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
                          child: const Text('Suivant'),
                        ),
                      ] else
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.go(AppRoutes.login),
                            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                            child: const Text('Commencer', style: TextStyle(fontSize: 16, fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
