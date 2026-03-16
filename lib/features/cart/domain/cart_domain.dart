import '../../../core/error/failures.dart';

// ═══════════════════════════════════════════════
// ENTITIES
// ═══════════════════════════════════════════════
class CartItemEntity {
  final String productId;
  final String restaurantId;
  final String restaurantName;
  final String productName;
  final String? photo;
  final double basePrice;
  final double extraPrice;
  final int quantity;
  final Map<String, String> selectedOptions;
  final String? notes;

  const CartItemEntity({
    required this.productId,
    required this.restaurantId,
    required this.restaurantName,
    required this.productName,
    this.photo,
    required this.basePrice,
    this.extraPrice = 0,
    this.quantity = 1,
    this.selectedOptions = const {},
    this.notes,
  });

  double get unitPrice => basePrice + extraPrice;
  double get lineTotal => unitPrice * quantity;
  String get lineTotalLabel => '${lineTotal.toInt()} DZD';

  CartItemEntity copyWith({int? quantity, String? notes, Map<String, String>? options}) => CartItemEntity(
    productId: productId, restaurantId: restaurantId, restaurantName: restaurantName,
    productName: productName, photo: photo, basePrice: basePrice, extraPrice: extraPrice,
    quantity: quantity ?? this.quantity,
    notes: notes ?? this.notes,
    selectedOptions: options ?? selectedOptions,
  );

  @override
  bool operator ==(Object other) =>
      other is CartItemEntity && other.productId == productId &&
      other.selectedOptions.toString() == selectedOptions.toString();

  @override
  int get hashCode => productId.hashCode ^ selectedOptions.hashCode;
}

class CartEntity {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItemEntity> items;
  final String? promoCode;
  final double promoDiscount;
  final double deliveryFee;
  final double minOrder;

  const CartEntity({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
    this.promoCode,
    this.promoDiscount = 0,
    this.deliveryFee = 0,
    this.minOrder = 0,
  });

  static const empty = CartEntity();

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get totalItems => items.fold(0, (s, i) => s + i.quantity);
  double get subtotal => items.fold(0.0, (s, i) => s + i.lineTotal);
  double get total => subtotal + deliveryFee - promoDiscount;
  bool get meetsMinOrder => subtotal >= minOrder;
  bool get hasPromo => promoCode != null && promoDiscount > 0;

  String get totalLabel => '${total.toInt()} DZD';
  String get subtotalLabel => '${subtotal.toInt()} DZD';
  String get deliveryFeeLabel => deliveryFee == 0 ? 'Gratuit' : '${deliveryFee.toInt()} DZD';

  CartEntity copyWith({
    List<CartItemEntity>? items,
    String? promoCode,
    double? promoDiscount,
    double? deliveryFee,
  }) => CartEntity(
    restaurantId: restaurantId, restaurantName: restaurantName,
    minOrder: minOrder,
    items: items ?? this.items,
    promoCode: promoCode ?? this.promoCode,
    promoDiscount: promoDiscount ?? this.promoDiscount,
    deliveryFee: deliveryFee ?? this.deliveryFee,
  );
}

// ═══════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════
abstract class CartRepository {
  CartEntity getCart();
  Future<Result<CartEntity>> addItem(CartItemEntity item);
  Future<Result<CartEntity>> removeItem(String productId);
  Future<Result<CartEntity>> updateQuantity(String productId, int quantity);
  Future<Result<CartEntity>> applyPromoCode(String code);
  Future<void> removePromoCode();
  Future<void> clearCart();
  Future<Result<CartEntity>> setDeliveryFee(double fee);
  Stream<CartEntity> watchCart();
}

// ═══════════════════════════════════════════════
// USE CASES
// ═══════════════════════════════════════════════
class AddToCartUseCase {
  final CartRepository _repo;
  const AddToCartUseCase(this._repo);

  Future<Result<CartEntity>> call({
    required CartItemEntity item,
    required CartEntity currentCart,
    required bool Function() askClearConfirmation,
  }) async {
    // Different restaurant check
    if (currentCart.restaurantId != null && currentCart.restaurantId != item.restaurantId) {
      if (!askClearConfirmation()) {
        return Either.left(const CartFailure(message: 'Opération annulée'));
      }
      await _repo.clearCart();
    }
    // Quantity check
    final existing = currentCart.items.where((i) => i.productId == item.productId).fold(0, (s, i) => s + i.quantity);
    if (existing + item.quantity > 20) {
      return Either.left(const CartFailure(message: 'Quantité maximum atteinte (20 par article)'));
    }
    return _repo.addItem(item);
  }
}

class ApplyPromoUseCase {
  final CartRepository _repo;
  const ApplyPromoUseCase(this._repo);

  Future<Result<CartEntity>> call(String code, CartEntity cart) async {
    if (code.trim().isEmpty) {
      return Either.left(const CartFailure(message: 'Entrez un code promo'));
    }
    if (cart.isEmpty) {
      return Either.left(const CartFailure(message: 'Le panier est vide'));
    }
    return _repo.applyPromoCode(code.trim().toUpperCase());
  }
}

class CheckoutValidationUseCase {
  const CheckoutValidationUseCase();

  Result<void> call({required CartEntity cart, required bool hasAddress}) {
    if (cart.isEmpty) return Either.left(const CartFailure(message: 'Votre panier est vide'));
    if (!hasAddress) return Either.left(const CartFailure(message: 'Veuillez sélectionner une adresse de livraison'));
    if (!cart.meetsMinOrder) return Either.left(CartFailure(message: 'Commande minimum: ${cart.minOrder.toInt()} DZD'));
    return const Either.right(null);
  }
}
