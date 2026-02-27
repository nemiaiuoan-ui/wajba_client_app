import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart' as mymodels;

//
// ================= CART PROVIDER =================
//

class CartProvider extends ChangeNotifier {
  final List<mymodels.CartItem> _items = [];
  String _restaurantId = '';
  String _restaurantName = '';

  List<mymodels.CartItem> get items => List.unmodifiable(_items);
  String get restaurantId => _restaurantId;
  String get restaurantName => _restaurantName;
  bool get isEmpty => _items.isEmpty;

  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.total);

  int total(int deliveryFee) => subtotal + deliveryFee;

  int quantityOf(String productId) {
    final index =
        _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) return _items[index].quantity;
    return 0;
  }

  void addItem(
      mymodels.Product product,
      String restId,
      String restName) {
    if (_restaurantId.isNotEmpty &&
        _restaurantId != restId) {
      clearCart();
    }

    _restaurantId = restId;
    _restaurantName = restName;

    final index =
        _items.indexWhere((i) => i.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(mymodels.CartItem(product: product));
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    final index =
        _items.indexWhere((i) => i.product.id == productId);

    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    if (_items.isEmpty) {
      _restaurantId = '';
      _restaurantName = '';
    }

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _restaurantId = '';
    _restaurantName = '';
    notifyListeners();
  }
}

//
// ================= RESTAURANT PROVIDER =================
//

class RestaurantProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<mymodels.Restaurant> _restaurants = [];
  mymodels.Restaurant? _selected;
  List<mymodels.Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<mymodels.Restaurant> get restaurants => _restaurants;
  mymodels.Restaurant? get selected => _selected;
  List<mymodels.Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<String> get productCategories =>
      _products.map((p) => p.category).toSet().toList();

  List<mymodels.Product> productsByCategory(String cat) =>
      cat == 'Tous'
          ? _products
          : _products.where((p) => p.category == cat).toList();

  List<mymodels.Restaurant> search(String query) {
    if (query.isEmpty) return _restaurants;
    final q = query.toLowerCase();
    return _restaurants
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q))
        .toList();
  }

  Future<void> loadRestaurants() async {
    _setLoading(true);
    try {
      final snap = await _db
          .collection('restaurants')
          .where('isOpen', isEqualTo: true)
          .get();

      _restaurants = snap.docs
          .map((d) =>
              mymodels.Restaurant.fromMap(d.id, d.data()))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError("Impossible de charger les restaurants");
    }
  }

  Future<void> loadRestaurantDetail(String id) async {
    _setLoading(true);
    try {
      final doc =
          await _db.collection('restaurants').doc(id).get();

      if (doc.exists) {
        _selected =
            mymodels.Restaurant.fromMap(id, doc.data()!);
      }

      final prodSnap = await _db
          .collection('restaurants')
          .doc(id)
          .collection('products')
          .where('isAvailable', isEqualTo: true)
          .get();

      _products = prodSnap.docs
          .map((d) =>
              mymodels.Product.fromMap(d.id, d.data()))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError("Impossible de charger le restaurant");
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String e) {
    _error = e;
    _isLoading = false;
    notifyListeners();
  }
}

//
// ================= ORDER PROVIDER =================
//

class OrderProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<mymodels.Order> _orders = [];
  bool _isLoading = false;
  String _error = '';

  List<mymodels.Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<String?> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<mymodels.CartItem> items,
    required String address,
    required String paymentMethod,
    required int deliveryFee,
  }) async {
    _setLoading(true);

    try {
      final subtotal =
          items.fold<int>(0, (s, i) => s + i.total);

      final total = subtotal + deliveryFee;

      final doc = await _db.collection('orders').add({
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'items': items.map((i) => i.toMap()).toList(),
        'status': 'pending',
        'address': address,
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return doc.id;
    } catch (e) {
      _setError("Erreur lors de la commande");
      return null;
    }
  }

  Future<void> loadOrders(String userId) async {
    _setLoading(true);
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snap.docs
          .map((d) =>
              mymodels.Order.fromMap(d.id, d.data()))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError("Impossible de charger les commandes");
    }
  }

  Stream<mymodels.Order> trackOrder(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((s) =>
            mymodels.Order.fromMap(s.id, s.data()!));
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String e) {
    _error = e;
    _isLoading = false;
    notifyListeners();
  }
}
