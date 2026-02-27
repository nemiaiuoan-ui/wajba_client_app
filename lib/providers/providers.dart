// — ORDER PROVIDER —
class OrderProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<mymodels.Order> _orders = [];
  mymodels.Order? _activeOrder;
  bool _isLoading = false;
  String _error = '';

  List<mymodels.Order> get orders => _orders;
  mymodels.Order? get activeOrder => _activeOrder;
  bool get isLoading => _isLoading;
  String get error => _error;

  // — Passer une commande —
  Future<String?> placeOrder({
    required String userId,
    required String restaurantId,
    required String restaurantName,
    required List<CartItem> items,
    required String address,
    required String paymentMethod,
    required int deliveryFee,
  }) async {
    _setLoading(true);
    try {
      final subtotal = items.fold<int>(0, (s, i) => s + i.total);
      final total = subtotal + deliveryFee;

      final doc = await _db.collection('orders').add({
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'items': items.map((i) => i.toMap()).toList(),
        'status': OrderStatus.pending.name,
        'address': address,
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'estimatedTime': 35,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return doc.id;
    } catch (e) {
      _setError("Erreur lors de la commande");
      return null;
    }
  }

  // — Charger les commandes —
  Future<void> loadOrders(String userId) async {
    _setLoading(true);
    try {
      final snap = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snap.docs
          .map((d) => mymodels.Order.fromMap(d.id, d.data()))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError("Impossible de charger les commandes");
    }
  }

  // — Suivi en temps réel —
  Stream<mymodels.Order> trackOrder(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((s) => mymodels.Order.fromMap(s.id, s.data()!));
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