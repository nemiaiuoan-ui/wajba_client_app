import '../../../core/error/failures.dart';
import '../../cart/domain/cart_domain.dart';

// ═══════════════════════════════════════════════
// ENTITIES
// ═══════════════════════════════════════════════
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  picked_up,
  delivered,
  cancelled,
}

extension OrderStatusExt on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending    => 'En attente',
    OrderStatus.confirmed  => 'Confirmée',
    OrderStatus.preparing  => 'En préparation',
    OrderStatus.ready      => 'Prête',
    OrderStatus.picked_up  => 'En route',
    OrderStatus.delivered  => 'Livrée',
    OrderStatus.cancelled  => 'Annulée',
  };

  String get emoji => switch (this) {
    OrderStatus.pending    => '⏳',
    OrderStatus.confirmed  => '✅',
    OrderStatus.preparing  => '👨‍🍳',
    OrderStatus.ready      => '📦',
    OrderStatus.picked_up  => '🛵',
    OrderStatus.delivered  => '🎉',
    OrderStatus.cancelled  => '❌',
  };

  int get step => switch (this) {
    OrderStatus.pending    => 0,
    OrderStatus.confirmed  => 1,
    OrderStatus.preparing  => 2,
    OrderStatus.ready      => 3,
    OrderStatus.picked_up  => 4,
    OrderStatus.delivered  => 5,
    OrderStatus.cancelled  => -1,
  };

  bool get isActive => this != OrderStatus.delivered && this != OrderStatus.cancelled;
  bool get canTrack  => this == OrderStatus.picked_up || this == OrderStatus.ready;
  bool get canCancel => this == OrderStatus.pending || this == OrderStatus.confirmed;
}

class AddressEntity {
  final String id;
  final String label;
  final String fullAddress;
  final String commune;
  final double lat;
  final double lng;
  final bool isDefault;
  final String? details;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.commune,
    required this.lat,
    required this.lng,
    this.isDefault = false,
    this.details,
  });

  String get labelIcon => switch (label.toLowerCase()) {
    'maison' => '🏠',
    'bureau' => '🏢',
    _ => '📍',
  };
}

class DriverInfoEntity {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehiclePlate;
  final double lat;
  final double lng;

  const DriverInfoEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehiclePlate,
    required this.lat,
    required this.lng,
  });
}

class OrderEntity {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String? restaurantLogo;
  final List<CartItemEntity> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final OrderStatus status;
  final AddressEntity deliveryAddress;
  final DriverInfoEntity? driver;
  final DateTime createdAt;
  final int? estimatedMinutes;
  final bool isRated;
  final String? cancellationReason;

  const OrderEntity({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    this.restaurantLogo,
    required this.items,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.driver,
    required this.createdAt,
    this.estimatedMinutes,
    this.isRated = false,
    this.cancellationReason,
  });

  String get idShort => id.length >= 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase();
  String get totalLabel => '${total.toInt()} DZD';
  bool get canRate => status == OrderStatus.delivered && !isRated;
}

// ═══════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════
abstract class OrderRepository {
  FutureResult<OrderEntity> placeOrder({
    required CartEntity cart,
    required AddressEntity address,
    required String paymentMethod,
    String? notes,
  });
  FutureResult<List<OrderEntity>> getOrders({int page = 1, int limit = 20});
  FutureResult<OrderEntity> getOrderById(String id);
  FutureResult<OrderEntity> cancelOrder(String id, String reason);
  FutureResult<void> rateOrder({required String id, required int rating, String? comment});
  Stream<OrderEntity> watchOrder(String id);
}

// ═══════════════════════════════════════════════
// USE CASES
// ═══════════════════════════════════════════════
class PlaceOrderUseCase {
  final OrderRepository _repo;
  const PlaceOrderUseCase(this._repo);

  FutureResult<OrderEntity> call({
    required CartEntity cart,
    required AddressEntity address,
    required String paymentMethod,
    String? notes,
  }) {
    if (cart.isEmpty) {
      return Future.value(Either.left(const OrderFailure(message: 'Le panier est vide')));
    }
    if (!cart.meetsMinOrder) {
      return Future.value(Either.left(OrderFailure(message: 'Commande minimum: ${cart.minOrder.toInt()} DZD (actuel: ${cart.subtotal.toInt()} DZD)')));
    }
    return _repo.placeOrder(cart: cart, address: address, paymentMethod: paymentMethod, notes: notes);
  }
}

class GetOrdersUseCase {
  final OrderRepository _repo;
  const GetOrdersUseCase(this._repo);
  FutureResult<List<OrderEntity>> call({int page = 1}) => _repo.getOrders(page: page);
}

class CancelOrderUseCase {
  final OrderRepository _repo;
  const CancelOrderUseCase(this._repo);

  FutureResult<OrderEntity> call(String id, String reason) {
    if (reason.trim().isEmpty) {
      return Future.value(Either.left(const OrderFailure(message: 'Veuillez indiquer la raison de l\'annulation')));
    }
    return _repo.cancelOrder(id, reason);
  }
}

class RateOrderUseCase {
  final OrderRepository _repo;
  const RateOrderUseCase(this._repo);

  FutureResult<void> call({required String id, required int rating, String? comment}) {
    if (rating < 1 || rating > 5) {
      return Future.value(Either.left(const OrderFailure(message: 'Note invalide (1-5)')));
    }
    return _repo.rateOrder(id: id, rating: rating, comment: comment);
  }
}
