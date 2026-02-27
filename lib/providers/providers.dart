import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// ─── CART PROVIDER ────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String _restaurantId   = '';
  String _restaurantName = '';

  List<CartItem> get items        => List.unmodifiable(_items);
  String get restaurantId         => _restaurantId;
  String get restaurantName       => _restaurantName;
  bool   get isEmpty              => _items.isEmpty;
  int    get itemCount            => _items.fold(0, (s, i) => s + i.quantity);

  int get subtotal => _items.fold(0, (s, i) => s + i.total);
  int deliveryFee(int fee) => isEmpty ? 0 : fee;
  int total(int fee) => subtotal + deliveryFee(fee);

  void addItem(Product product, String restId, String restName) {
    // Si panier d'un autre restaurant → vider d'abord
    if (_restaurantId.isNotEmpty && _restaurantId != restId) {
      clearCart();
    }
    _restaurantId   = restId;
    _restaurantName = restName;

    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    if (_items[idx].quantity > 1) {
      _items[idx].quantity--;
    } else {
      _items.removeAt(idx);
    }
    if (_items.isEmpty) _restaurantId = '';
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId   = '';
    _restaurantName = '';
    notifyListeners();
  }

  int quantityOf(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? _items[idx].quantity : 0;
  }
}

// ─── RESTAURANT PROVIDER ──────────────────────────────────────────
class RestaurantProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<Restaurant> _restaurants = [];
  Restaurant?      _selected;
  List<Product>    _products    = [];
  bool _isLoading  = false;
  String _error    = '';

  List<Restaurant> get restaurants => _restaurants;
  Restaurant?      get selected    => _selected;
  List<Product>    get products    => _products;
  bool             get isLoading   => _isLoading;
  String           get error       => _error;

  // ── Charger liste restaurants ──────────────────────────────────
  Future<void> loadRestaurants() async {
    _setLoading(true);
    try {
      final snap = await _db
          .collection('restaurants')
          .where('isOpen', isEqualTo: true)
          .get();
      _restaurants = snap.docs
          .map((d) => Restaurant.fromMap(d.id, d.data()))
          .toList();
      _setLoading(false);
    } catch (e) {
      _setError('Impossible de charger les restaurants');
    }
  }

  // ── Charger détail + produits ──────────────────────────────────
  Future<void> loadRestaurantDetail(String id) async {
    _setLoading(true);
    try {
      final doc = await _db.collection('restaurants').doc(id).get();
      if (doc.exists) {
        _selected = Restaurant.fromMap(id, doc.data()!);
      }
      final prodSnap = await _db
          .collection('restaurants')
          .doc(id)
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();
      _products = prodSnap.docs
          .map((d) => Product.fromMap(d.id, d.data()))
          .toList();
      _setLoading(false);
    } catch (e) {
      _setError('Impossible de charger le restaurant');
    }
  }

  // ── Rechercher ────────────────────────────────────────────────
  List<Restaurant> search(String query) {
    if (query.isEmpty) return _restaurants;
    final q = query.toLowerCase();
    return _restaurants.where((r) =>
      r.name.toLowerCase().contains(q) ||
      r.cuisine.toLowerCase().contains(q)
    ).toList();
  }

  // ── Produits par catégorie ─────────────────────────────────────
  List<String> get productCategories =>
    _products.map((p) => p.category).toSet().toList();

  List<Product> productsByCategory(String cat) =>
    cat == 'Tous' ? _products : _products.where((p) => p.category == cat).toList();

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String e) { _error = e; _isLoading = false; notifyListeners(); }
}

// ─── ORDER PROVIDER ───────────────────────────────────────────────
class OrderProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<Order> _orders    = [];
  Order?      _activeOrder;
  bool        _isLoading = false;
  String      _error     = '';

  List<Order> get orders      => _orders;
  Order?      get activeOrder => _activeOrder;
  bool        get isLoading   => _isLoading;
  String      get error       => _error;

  // ── Passer une commande ────────────────────────────────────────
  Future<String?> placeOrder({
    required String     userId,
    required String     restaurantId,
    required String     restaurantName,
    required List<CartItem> items,
    required String     address,
    required String     paymentMethod,
    required int        deliveryFee,
  }) async {
    _setLoading(true);
    try {
      final subtotal = items.fold<int>(0, (s, i) => s + i.total);
      final total    = subtotal + deliveryFee;

      final doc = await _db.collection('orders').add({
        'userId':         userId,
        'restaurantId':   restaurantId,
        'restaurantName': restaurantName,
        'items':          items.map((i) => i.toMap()).toList(),
        'status':         OrderStatus.pending.name,
        'address':        address,
        'paymentMethod':  paymentMethod,
        'subtotal':       subtotal,
        'deliveryFee':    deliveryFee,
        'total':          total,
        'estimatedTime':  35,
        'createdAt':      FieldValue.serverTimestamp(),
      });
      _setLoading(false);
      return doc.id;
    } catch (e) {
      _setError('Commande échouée, réessayez');
      return null;
    }
  }

  // ── Charger mes commandes ──────────────────────────────────────
  Future<void> loadOrders(String userId) async {
    _setLoading(true);
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _orders = snap.docs.map((d) => Order.fromMap(d.id, d.data())).toList();
      _setLoading(false);
    } catch (e) {
      _setError('Impossible de charger les commandes');
    }
  }

  // ── Suivre commande en temps réel ─────────────────────────────
  Stream<Order> trackOrder(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map(
      (s) => Order.fromMap(s.id, s.data()!),
    );
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String e) { _error = e; _isLoading = false; notifyListeners(); }
}
