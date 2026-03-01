import 'package:wajba_client/config/constants.dart';
import 'package:wajba_client/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/theme.dart';
import '../../widgets/widgets.dart';

class _Page {
  final String emoji, title, subtitle;
  const _Page(this.emoji, this.title, this.subtitle);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page   = 0;

  final _pages = const [
    _Page('🍕', 'Commandez vos plats préférés',
        'Des centaines de restaurants à portée de main partout en Algérie'),
    _Page('🛵', 'Livraison rapide',
        'Vos plats livrés en moins de 40 minutes directement chez vous'),
    _Page('📍', 'Suivez en temps réel',
        'Regardez votre commande avancer sur la carte jusqu\'à votre porte'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: WajbaColors.white,
    body: SafeArea(
      child: Column(
        children: [
          // ── Skip ────────────────────────────────────────────
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => context.go('/auth/phone'),
              child: const Text('Passer', style: TextStyle(color: WajbaColors.grey600)),
            ),
          ),

          // ── Pages ───────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _PageView(page: _pages[i]),
            ),
          ),

          // ── Indicator + Button ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(kPaddingL),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _ctrl,
                  count: _pages.length,
                  effect: WormEffect(
                    dotWidth:  10,
                    dotHeight: 10,
                    activeDotColor: WajbaColors.primary,
                    dotColor: WajbaColors.grey200,
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton Suivant / Commencer
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _page < _pages.length - 1
                    ? WajbaButton(
                        key: const ValueKey('next'),
                        label: 'Suivant',
                        icon: Icons.arrow_forward,
                        onTap: () => _ctrl.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        ),
                      )
                    : WajbaButton(
                        key: const ValueKey('start'),
                        label: 'Commencer',
                        icon: Icons.restaurant_menu,
                        onTap: () => context.go('/auth/phone'),
                      ),
                ),
                const SizedBox(height: 12),

                // Se connecter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ? ',
                      style: TextStyle(color: WajbaColors.grey600)),
                    GestureDetector(
                      onTap: () => context.go('/auth/phone'),
                      child: const Text('Se connecter',
                        style: TextStyle(
                          color: WajbaColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PageView extends StatelessWidget {
  final _Page page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: kPaddingXL),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(page.emoji, style: const TextStyle(fontSize: 100)),
        const SizedBox(height: 32),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: WajbaColors.dark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          page.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: WajbaColors.grey600,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
