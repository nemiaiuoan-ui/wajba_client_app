// ─── CONFIGURATION FIREBASE ──────────────────────────────────────
// INSTRUCTIONS :
// 1. Allez sur https://console.firebase.google.com
// 2. Créez un projet "wajba-app"
// 3. Ajoutez une app Android avec package: com.wajba.client
// 4. Téléchargez google-services.json → mettez-le dans android/app/
// 5. Activez Authentication > Phone, Firestore, Storage

class FirebaseConfig {
  // Ces valeurs viennent automatiquement de google-services.json
  // Ne rien changer ici manuellement
  static const projectId = 'wajba-app'; // À changer avec votre vrai project ID
}

// ─── STRUCTURE FIRESTORE ──────────────────────────────────────────
// Collection: users/{uid}
//   - name: String
//   - phone: String
//   - email: String
//   - address: String
//   - photoUrl: String
//   - createdAt: Timestamp
//   - fcmToken: String
//
// Collection: restaurants/{id}
//   - name: String
//   - cuisine: String
//   - address: String
//   - phone: String
//   - logoUrl: String
//   - bannerUrl: String
//   - rating: double
//   - deliveryTime: int (minutes)
//   - deliveryFee: int (DA)
//   - minOrder: int (DA)
//   - isOpen: bool
//   - categories: List<String>
//   - location: GeoPoint
//
// Sub-collection: restaurants/{id}/products/{pid}
//   - name: String
//   - description: String
//   - price: int (DA)
//   - imageUrl: String
//   - category: String
//   - isAvailable: bool
//
// Collection: orders/{id}
//   - userId: String
//   - restaurantId: String
//   - restaurantName: String
//   - items: List<Map>
//   - status: String (pending|confirmed|preparing|ready|delivering|delivered|cancelled)
//   - address: String
//   - paymentMethod: String
//   - subtotal: int
//   - deliveryFee: int
//   - total: int
//   - driverLocation: GeoPoint (live)
//   - createdAt: Timestamp
//   - estimatedTime: int (minutes)
