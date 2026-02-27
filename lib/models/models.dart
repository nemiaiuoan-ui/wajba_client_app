import 'package:cloud_firestore/cloud_firestore.dart';

// ─── USER ─────────────────────────────────────────────────────────
class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email    = '',
    this.address  = '',
    this.photoUrl = '',
    required this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> m) => UserModel(
    uid:       uid,
    name:      m['name']     ?? '',
    phone:     m['phone']    ?? '',
    email:     m['email']    ?? '',
    address:   m['address']  ?? '',
    photoUrl:  m['photoUrl'] ?? '',
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'name':      name,
    'phone':     phone,
    'email':     email,
    'address':   address,
    'photoUrl':  photoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  UserModel copyWith({String? name, String? email, String? address, String? photoUrl}) =>
    UserModel(
      uid: uid, phone: phone, createdAt: createdAt,
      name:     name     ?? this.name,
      email:    email    ?? this.email,
      address:  address  ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
    );
}

// ─── RESTAURANT ───────────────────────────────────────────────────
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String address;
  final String phone;
  final String logoUrl;
  final String bannerUrl;
  final double rating;
  final int    deliveryTime; // minutes
  final int    deliveryFee;  // DA
  final int    minOrder;     // DA
  final bool   isOpen;
  final List<String> categories;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.address,
    required this.phone,
    this.logoUrl   = '',
    this.bannerUrl = '',
    this.rating    = 0,
    this.deliveryTime = 30,
    this.deliveryFee  = 0,
    this.minOrder     = 500,
    this.isOpen       = true,
    this.categories   = const [],
  });

  factory Restaurant.fromMap(String id, Map<String, dynamic> m) => Restaurant(
    id:           id,
    name:         m['name']         ?? '',
    cuisine:      m['cuisine']      ?? '',
    address:      m['address']      ?? '',
    phone:        m['phone']        ?? '',
    logoUrl:      m['logoUrl']      ?? '',
    bannerUrl:    m['bannerUrl']    ?? '',
    rating:       (m['rating']      ?? 0).toDouble(),
    deliveryTime: m['deliveryTime'] ?? 30,
    deliveryFee:  m['deliveryFee']  ?? 0,
    minOrder:     m['minOrder']     ?? 500,
    isOpen:       m['isOpen']       ?? true,
    categories:   List<String>.from(m['categories'] ?? []),
  );
}

// ─── PRODUCT ──────────────────────────────────────────────────────
class Product {
  final String id;
  final String name;
  final String description;
  final int    price;  // DA
  final String imageUrl;
  final String category;
  final bool   isAvailable;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl    = '',
    this.category    = '',
    this.isAvailable = true,
  });

  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
    id:          id,
    name:        m['name']        ?? '',
    description: m['description'] ?? '',
    price:       m['price']       ?? 0,
    imageUrl:    m['imageUrl']    ?? '',
    category:    m['category']    ?? '',
    isAvailable: m['isAvailable'] ?? true,
  );
}

// ─── CART ITEM ────────────────────────────────────────────────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get total => product.price * quantity;

  Map<String, dynamic> toMap() => {
    'productId':   product.id,
    'name':        product.name,
    'price':       product.price,
    'quantity':    quantity,
    'imageUrl':    product.imageUrl,
  };
}

// ─── ORDER ────────────────────────────────────────────────────────
enum OrderStatus {
  pending, confirmed, preparing, ready, delivering, delivered, cancelled
}

extension OrderStatusExt on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:    return 'En attente';
      case OrderStatus.confirmed:  return 'Confirmée';
      case OrderStatus.preparing:  return 'En préparation';
      case OrderStatus.ready:      return 'Prête';
      case OrderStatus.delivering: return 'En livraison';
      case OrderStatus.delivered:  return 'Livrée';
      case OrderStatus.cancelled:  return 'Annulée';
    }
  }

  static OrderStatus fromString(String s) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final String      id;
  final String      userId;
  final String      restaurantId;
  final String      restaurantName;
  final List<Map>   items;
  final OrderStatus status;
  final String      address;
  final String      paymentMethod;
  final int         subtotal;
  final int         deliveryFee;
  final int         total;
  final DateTime    createdAt;
  final int         estimatedTime;

  const Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.createdAt,
    this.estimatedTime = 30,
  });

  factory Order.fromMap(String id, Map<String, dynamic> m) => Order(
    id:             id,
    userId:         m['userId']         ?? '',
    restaurantId:   m['restaurantId']   ?? '',
    restaurantName: m['restaurantName'] ?? '',
    items:          List<Map>.from(m['items'] ?? []),
    status:         OrderStatusExt.fromString(m['status'] ?? 'pending'),
    address:        m['address']        ?? '',
    paymentMethod:  m['paymentMethod']  ?? 'cash',
    subtotal:       m['subtotal']       ?? 0,
    deliveryFee:    m['deliveryFee']    ?? 0,
    total:          m['total']          ?? 0,
    createdAt:      (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    estimatedTime:  m['estimatedTime']  ?? 30,
  );
}
