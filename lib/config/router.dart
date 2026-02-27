import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/phone_auth_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/restaurant/restaurant_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider auth) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = auth.isLoggedIn;
      final isOnAuth   = state.matchedLocation.startsWith('/auth') ||
                         state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isOnAuth) return '/onboarding';
      if (isLoggedIn  &&  isOnAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),

      // ── Onboarding & Auth ──
      GoRoute(path: '/onboarding',  builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth/phone',  builder: (_, __) => const PhoneAuthScreen()),
      GoRoute(path: '/auth/otp',    builder: (_, s) => OtpScreen(
        phone: s.extra as String? ?? '',
        verificationId: (s.extra as Map<String, String>?)?['verificationId'] ?? '',
      )),
      GoRoute(path: '/auth/profile', builder: (_, __) => const ProfileSetupScreen()),

      // ── Main app (tabs) ──
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/orders',  builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Standalone screens ──
      GoRoute(
        path: '/restaurant/:id',
        builder: (_, s) => RestaurantDetailScreen(restaurantId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/cart',     builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: '/order-tracking/:orderId',
        builder: (_, s) => OrderTrackingScreen(orderId: s.pathParameters['orderId']!),
      ),
      GoRoute(path: '/edit-profile', builder: (_, __) => const EditProfileScreen()),
    ],
  );
}
