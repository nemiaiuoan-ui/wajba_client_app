# 🍽️ WAJBA CLIENT APP — Guide de démarrage complet

## 📁 Structure du projet

```
wajba_client_app/
├── lib/
│   ├── main.dart                          ← Point d'entrée
│   ├── config/
│   │   ├── theme.dart                     ← Couleurs & Thème
│   │   ├── router.dart                    ← Navigation
│   │   └── firebase_config.dart           ← Structure Firestore
│   ├── models/
│   │   └── models.dart                    ← User, Restaurant, Product, Order
│   ├── providers/
│   │   ├── auth_provider.dart             ← Auth Firebase (SMS OTP)
│   │   └── providers.dart                 ← Cart, Restaurant, Order
│   ├── widgets/
│   │   └── widgets.dart                   ← Composants réutilisables
│   └── screens/
│       ├── onboarding/                    ← 3 slides d'intro
│       ├── auth/                          ← Téléphone → OTP → Profil
│       ├── home/                          ← Liste restaurants + recherche
│       ├── restaurant/                    ← Détail + menu + panier
│       ├── cart/                          ← Panier
│       ├── checkout/                      ← Commande + paiement
│       ├── orders/                        ← Historique commandes
│       │   └── order_tracking_screen.dart ← Suivi temps réel
│       └── profile/                       ← Profil utilisateur
├── android/
│   └── app/src/main/AndroidManifest.xml
└── pubspec.yaml
```

---

## 🔥 ÉTAPE 1 — Créer le projet Firebase

1. Allez sur **https://console.firebase.google.com**
2. Cliquez **"Créer un projet"** → Nom: `wajba-app`
3. Désactivez Google Analytics (optionnel)
4. Une fois créé, cliquez **"Ajouter une application"** → Android

### Configuration Android :
- **Package name :** `com.wajba.client`
- **Nom de l'app :** Wajba
- Téléchargez **`google-services.json`**
- Placez-le dans `android/app/google-services.json`

---

## 🔐 ÉTAPE 2 — Activer les services Firebase

Dans la console Firebase :

### Authentication
1. Menu → **Authentication** → **Sign-in method**
2. Activer **"Téléphone"**
3. Pour les tests, ajoutez votre numéro dans "Numéros de test" :
   - Numéro : `+213 600 000 000`
   - Code : `123456`

### Firestore Database
1. Menu → **Firestore Database** → **Créer une base de données**
2. Choisir **mode production** (ou test pour commencer)
3. Région : `europe-west` (plus proche de l'Algérie)

### Règles Firestore (copiez ceci) :
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users: lecture/écriture par le propriétaire uniquement
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Restaurants: lecture publique, écriture admin seulement
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if false; // L'admin panel gère ça
      match /products/{productId} {
        allow read: if true;
        allow write: if false;
      }
    }
    // Orders: l'utilisateur voit seulement ses commandes
    match /orders/{orderId} {
      allow read: if request.auth != null && 
                     resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if false; // Seul le driver/admin met à jour
    }
  }
}
```

### Storage (images)
1. Menu → **Storage** → **Commencer**
2. Mode test pour commencer

---

## 📦 ÉTAPE 3 — Installer Flutter

Si Flutter n'est pas installé :
1. Téléchargez : **https://flutter.dev/docs/get-started/install**
2. Vérifiez : `flutter doctor`

---

## 🚀 ÉTAPE 4 — Lancer l'application

```bash
# 1. Aller dans le dossier
cd wajba_client_app

# 2. Installer les dépendances
flutter pub get

# 3. Vérifier la configuration
flutter doctor

# 4. Lancer sur émulateur ou téléphone connecté
flutter run

# 5. Build APK pour test
flutter build apk --release

# L'APK sera dans: build/outputs/flutter-apk/app-release.apk
```

---

## 🗄️ ÉTAPE 5 — Ajouter des données de test dans Firestore

Dans la console Firebase → Firestore → **Ajouter manuellement** :

### Collection `restaurants` :
```json
{
  "name": "El Kasbah",
  "cuisine": "Cuisine Algérienne",
  "address": "Rue Didouche Mourad, Alger",
  "phone": "+213 21 63 00 00",
  "rating": 4.8,
  "deliveryTime": 25,
  "deliveryFee": 0,
  "minOrder": 500,
  "isOpen": true,
  "categories": ["Plats", "Soupes", "Desserts"],
  "logoUrl": "https://via.placeholder.com/200",
  "bannerUrl": "https://via.placeholder.com/800x400"
}
```

### Sub-collection `products` (dans ce restaurant) :
```json
{
  "name": "Couscous Merguez",
  "description": "Couscous traditionnel avec merguez grillées",
  "price": 1500,
  "category": "Plats",
  "imageUrl": "https://via.placeholder.com/300",
  "isAvailable": true
}
```

---

## 🎨 Identité visuelle
- **Rouge principal :** `#C62828`
- **Noir :** `#121212`
- **Blanc :** `#FFFFFF`
- **Police :** Poppins (incluse dans pubspec.yaml)

> ⚠️ Téléchargez les polices Poppins depuis Google Fonts et mettez-les dans `assets/fonts/`

---

## 📱 Fonctionnalités incluses

| Fonctionnalité | Statut |
|---|---|
| Onboarding 3 slides | ✅ |
| Auth téléphone (OTP Firebase) | ✅ |
| Profil utilisateur | ✅ |
| Liste restaurants (Firestore) | ✅ |
| Recherche restaurants | ✅ |
| Détail restaurant + menu | ✅ |
| Panier multi-produits | ✅ |
| Checkout (adresse + paiement) | ✅ |
| Passer commande (Firestore) | ✅ |
| Suivi commande temps réel | ✅ |
| Historique commandes | ✅ |
| Modifier profil | ✅ |
| Navigation fluide (go_router) | ✅ |

---

## 🔜 Prochaines étapes
1. **Admin Panel React** → Gérer restaurants et commandes
2. **Driver App Flutter** → Livraison et navigation GPS
3. **Notifications push** → Firebase Messaging
4. **Paiement en ligne** → Intégration CIB/BaridiMob
