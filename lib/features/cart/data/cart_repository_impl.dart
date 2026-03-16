import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../domain/cart_domain.dart';

// ═══════════════════════════════════════════════
// CART REPOSITORY IMPLEMENTATION
// ═══════════════════════════════════════════════
class CartRepositoryImpl implements CartRepository {
  static const _boxName = 'cart';
  static const _cartKey = 'current_cart';
  final _controller = StreamController<CartEntity>.broadcast();

  CartRepositoryImpl() { _initBox(); }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(_boxName)) await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  @override
  CartEntity getCart() {
    final raw = _box.get(_cartKey);
    if (raw == null) return CartEntity.empty;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      return _fromJson(json);
    } catch (_) {
      return CartEntity.empty;
    }
  }

  @override
  Stream<CartEntity> watchCart() => _controller.stream;

  @override
  Future<Result<CartEntity>> addItem(CartItemEntity item) => safeCall(() async {
    final cart = getCart();
    final existingIdx = cart.items.indexWhere((i) => i == item);
    List<CartItemEntity> newItems;

    if (existingIdx >= 0) {
      newItems = [...cart.items];
      newItems[existingIdx] = newItems[existingIdx].copyWith(
        quantity: newItems[existingIdx].quantity + item.quantity,
      );
    } else {
      newItems = [...cart.items, item];
    }

    final updated = CartEntity(
      restaurantId: item.restaurantId,
      restaurantName: item.restaurantName,
      items: newItems,
      deliveryFee: cart.deliveryFee,
      promoCode: cart.promoCode,
      promoDiscount: cart.promoDiscount,
      minOrder: cart.minOrder,
    );
    await _persist(updated);
    return updated;
  });

  @override
  Future<Result<CartEntity>> removeItem(String productId) => safeCall(() async {
    final cart = getCart();
    final newItems = cart.items.where((i) => i.productId != productId).toList();
    final updated = newItems.isEmpty ? CartEntity.empty : cart.copyWith(items: newItems);
    await _persist(updated);
    return updated;
  });

  @override
  Future<Result<CartEntity>> updateQuantity(String productId, int quantity) => safeCall(() async {
    if (quantity <= 0) {
      final result = await removeItem(productId);
      return result.right;
    }
    final cart = getCart();
    final newItems = cart.items.map((i) => i.productId == productId ? i.copyWith(quantity: quantity) : i).toList();
    final updated = cart.copyWith(items: newItems);
    await _persist(updated);
    return updated;
  });

  @override
  Future<Result<CartEntity>> applyPromoCode(String code) => safeCall(() async {
    // Call API to validate promo
    final res = await ApiClient.instance.post('/promo/validate', data: {'code': code});
    final discount = (res.data['discount'] as num).toDouble();
    final discountType = res.data['type'] as String; // 'percent' | 'fixed'
    final cart = getCart();
    final discountAmount = discountType == 'percent'
        ? cart.subtotal * (discount / 100)
        : discount;

    final updated = cart.copyWith(promoCode: code, promoDiscount: discountAmount);
    await _persist(updated);
    return updated;
  });

  @override
  Future<void> removePromoCode() async {
    final cart = getCart();
    final updated = CartEntity(
      restaurantId: cart.restaurantId, restaurantName: cart.restaurantName,
      items: cart.items, deliveryFee: cart.deliveryFee, minOrder: cart.minOrder,
    );
    await _persist(updated);
  }

  @override
  Future<void> clearCart() async {
    await _box.delete(_cartKey);
    _controller.add(CartEntity.empty);
  }

  @override
  Future<Result<CartEntity>> setDeliveryFee(double fee) => safeCall(() async {
    final cart = getCart();
    final updated = cart.copyWith(deliveryFee: fee);
    await _persist(updated);
    return updated;
  });

  Future<void> _persist(CartEntity cart) async {
    final json = _toJson(cart);
    await _box.put(_cartKey, jsonEncode(json));
    _controller.add(cart);
  }

  Map<String, dynamic> _toJson(CartEntity cart) => {
    'restaurant_id': cart.restaurantId,
    'restaurant_name': cart.restaurantName,
    'delivery_fee': cart.deliveryFee,
    'promo_code': cart.promoCode,
    'promo_discount': cart.promoDiscount,
    'min_order': cart.minOrder,
    'items': cart.items.map((i) => {
      'product_id': i.productId,
      'restaurant_id': i.restaurantId,
      'restaurant_name': i.restaurantName,
      'product_name': i.productName,
      'photo': i.photo,
      'base_price': i.basePrice,
      'extra_price': i.extraPrice,
      'quantity': i.quantity,
      'notes': i.notes,
      'selected_options': i.selectedOptions,
    }).toList(),
  };

  CartEntity _fromJson(Map<String, dynamic> json) => CartEntity(
    restaurantId: json['restaurant_id'],
    restaurantName: json['restaurant_name'],
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
    promoCode: json['promo_code'],
    promoDiscount: (json['promo_discount'] as num?)?.toDouble() ?? 0,
    minOrder: (json['min_order'] as num?)?.toDouble() ?? 0,
    items: (json['items'] as List? ?? []).map((i) => CartItemEntity(
      productId: i['product_id'],
      restaurantId: i['restaurant_id'],
      restaurantName: i['restaurant_name'],
      productName: i['product_name'],
      photo: i['photo'],
      basePrice: (i['base_price'] as num).toDouble(),
      extraPrice: (i['extra_price'] as num?)?.toDouble() ?? 0,
      quantity: i['quantity'] ?? 1,
      notes: i['notes'],
      selectedOptions: Map<String, String>.from(i['selected_options'] ?? {}),
    )).toList(),
  );

  void dispose() => _controller.close();
}
