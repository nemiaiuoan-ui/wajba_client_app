# WAJBA Client — Application Flutter 🍽️

Application mobile de livraison alimentaire pour le marché algérien (Annaba).

## Stack
- **Flutter 3.x** + Dart 3
- **Riverpod 2** — State management
- **GoRouter** — Navigation
- **Dio** — HTTP client avec auto-refresh token
- **Google Maps** — Carte + suivi GPS temps réel
- **flutter_secure_storage** — JWT sécurisé

## Structure du projet

```
lib/
├── main.dart                          ← Entry point
├── core/
│   ├── theme/app_theme.dart           ← Couleurs WAJBA + Material Theme
│   ├── constants/app_constants.dart   ← URLs, routes, storage keys
│   ├── network/api_client.dart        ← Dio + intercepteurs JWT
│   ├── services/providers.dart        ← Riverpod providers globaux
│   └── navigation/router.dart        ← GoRouter + MainShell + bottom nav
├── shared/
│   └── models/models.dart             ← UserModel, Restaurant, Product, Cart, Order
└── features/
    ├── auth/
    │   ├── data/auth_service.dart     ← API Auth (OTP, login, logout)
    │   └── presentation/screens/
    │       ├── splash_screen.dart     ← Splash animée + OnboardingScreen
    │       └── login_screen.dart      ← Phone input + OTP verification (Pinput)
    ├── home/
    │   └── presentation/
    │       ├── screens/
    │       │   ├── home_screen.dart   ← Feed principal + catégories + tri
    │       │   └── search_screen.dart ← Recherche live + suggestions
    │       └── widgets/
    │           └── restaurant_card.dart ← Card restaurant + CategoryChip
    ├── restaurant/
    │   └── presentation/screens/
    │       └── restaurant_screen.dart ← Menu tabs + ajouter au panier
    ├── cart/
    │   └── presentation/screens/
    │       └── cart_screen.dart       ← Panier + code promo + checkout
    ├── order/
    │   └── presentation/screens/
    │       ├── tracking_screen.dart   ← Suivi GPS temps réel (Google Maps)
    │       └── orders_screen.dart    ← Historique + en cours + notation
    └── profile/
        └── presentation/screens/
            └── profile_screen.dart   ← Profil + adresses + déconnexion
```

## Écrans complets (10)

| Écran | Fonctionnalités |
|-------|----------------|
| 🚀 Splash | Animation logo + redirect auto |
| 📖 Onboarding | 3 pages swipables + indicator |
| 📱 Login | Numéro DZ + validation regex |
| 🔑 OTP | Pinput 4 chiffres + countdown + resend |
| 🏠 Home | Feed restaurants, catégories, bannière promo, tri |
| 🔍 Recherche | Live filter + suggestions + récents |
| 🍽️ Restaurant | Bannière, infos, menu tabs, add to cart |
| 🛒 Panier | Items, code promo, livraison, checkout |
| ✅ Confirmation | Animation + steps tracker |
| 🛵 Tracking | Google Maps live + bottom sheet livreur |
| 📋 Commandes | En cours + historique + notation |
| 👤 Profil | Stats + menu + déconnexion |
| 🔔 Notifications | Liste notifications |

## Connexion au Backend

Modifiez `lib/core/constants/app_constants.dart` :
```dart
static const String baseUrl = 'http://TON_IP:3000/api/v1';
static const String wsUrl = 'ws://TON_IP:3000';
```

## Setup rapide
```bash
flutter pub get
flutter run
```
