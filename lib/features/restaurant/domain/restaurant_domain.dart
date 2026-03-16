import '../../../core/error/failures.dart';

// ═══════════════════════════════════════════════
// ENTITIES
// ═══════════════════════════════════════════════
class CategoryEntity {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final bool isActive;
  final int restaurantCount;

  const CategoryEntity({
    required this.id, required this.name, required this.emoji,
    required this.color, this.isActive = true, this.restaurantCount = 0,
  });
}

class RestaurantEntity {
  final String id;
  final String name;
  final String? logo;
  final String? banner;
  final String cuisineType;
  final String address;
  final String commune;
  final double lat;
  final double lng;
  final double rating;
  final int reviewCount;
  final int deliveryTime;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final bool isVerified;
  final String? promoTag;
  final double? distance;
  final Map<String, dynamic>? hours;

  const RestaurantEntity({
    required this.id, required this.name, this.logo, this.banner,
    required this.cuisineType, required this.address, required this.commune,
    required this.lat, required this.lng,
    this.rating = 0, this.reviewCount = 0,
    this.deliveryTime = 30, this.deliveryFee = 0, this.minOrder = 0,
    this.isOpen = true, this.isVerified = true,
    this.promoTag, this.distance, this.hours,
  });

  String get deliveryTimeLabel => '$deliveryTime–${deliveryTime + 10} min';
  String get deliveryFeeLabel => deliveryFee == 0 ? 'Gratuit 🎉' : '${deliveryFee.toInt()} DZD';
  String get ratingLabel => rating.toStringAsFixed(1);
  bool get hasPromo => promoTag != null;
}

class ProductOptionEntity {
  final String id;
  final String name;
  final double extraPrice;
  const ProductOptionEntity({required this.id, required this.name, this.extraPrice = 0});
  String get priceLabel => extraPrice > 0 ? '+${extraPrice.toInt()} DZD' : 'Inclus';
}

class ProductOptionGroupEntity {
  final String id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<ProductOptionEntity> options;
  const ProductOptionGroupEntity({
    required this.id, required this.name,
    this.required = false, this.maxSelections = 1,
    required this.options,
  });
}

class ProductEntity {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String? photo;
  final double price;
  final String category;
  final bool isAvailable;
  final bool isFeatured;
  final String? badge;
  final List<ProductOptionGroupEntity> optionGroups;

  const ProductEntity({
    required this.id, required this.restaurantId, required this.name,
    this.description, this.photo, required this.price, required this.category,
    this.isAvailable = true, this.isFeatured = false,
    this.badge, this.optionGroups = const [],
  });

  String get priceLabel => '${price.toInt()} DZD';
}

// ═══════════════════════════════════════════════
// FILTER VALUE OBJECT
// ═══════════════════════════════════════════════
class RestaurantFilter {
  final String? categoryId;
  final String? search;
  final SortOption sortBy;
  final double? maxDeliveryFee;
  final int? maxDeliveryTime;

  const RestaurantFilter({
    this.categoryId, this.search,
    this.sortBy = SortOption.rating,
    this.maxDeliveryFee, this.maxDeliveryTime,
  });

  RestaurantFilter copyWith({
    String? categoryId, String? search, SortOption? sortBy,
    double? maxDeliveryFee, int? maxDeliveryTime,
  }) => RestaurantFilter(
    categoryId: categoryId ?? this.categoryId,
    search: search ?? this.search,
    sortBy: sortBy ?? this.sortBy,
    maxDeliveryFee: maxDeliveryFee ?? this.maxDeliveryFee,
    maxDeliveryTime: maxDeliveryTime ?? this.maxDeliveryTime,
  );

  bool get hasFilter => categoryId != null || search != null || maxDeliveryFee != null || maxDeliveryTime != null;

  @override
  bool operator ==(Object other) =>
      other is RestaurantFilter &&
      other.categoryId == categoryId && other.search == search &&
      other.sortBy == sortBy;

  @override
  int get hashCode => categoryId.hashCode ^ search.hashCode ^ sortBy.hashCode;
}

enum SortOption { rating, distance, deliveryTime, deliveryFee }

extension SortOptionExt on SortOption {
  String get label => switch (this) {
    SortOption.rating => '⭐ Mieux notés',
    SortOption.distance => '📍 Plus proches',
    SortOption.deliveryTime => '⚡ Livraison rapide',
    SortOption.deliveryFee => '💰 Moins cher',
  };
}

// ═══════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════
abstract class RestaurantRepository {
  FutureResult<List<RestaurantEntity>> getRestaurants(RestaurantFilter filter);
  FutureResult<RestaurantEntity> getRestaurantById(String id);
  FutureResult<List<ProductEntity>> getMenu(String restaurantId);
  FutureResult<List<CategoryEntity>> getCategories();
  FutureResult<List<RestaurantEntity>> getFeaturedRestaurants();
  FutureResult<List<RestaurantEntity>> getNearbyRestaurants({required double lat, required double lng, double radiusKm = 5});
}

// ═══════════════════════════════════════════════
// USE CASES
// ═══════════════════════════════════════════════
class GetRestaurantsUseCase {
  final RestaurantRepository _repo;
  const GetRestaurantsUseCase(this._repo);
  FutureResult<List<RestaurantEntity>> call(RestaurantFilter filter) => _repo.getRestaurants(filter);
}

class GetRestaurantDetailUseCase {
  final RestaurantRepository _repo;
  const GetRestaurantDetailUseCase(this._repo);
  FutureResult<RestaurantEntity> call(String id) => _repo.getRestaurantById(id);
}

class GetMenuUseCase {
  final RestaurantRepository _repo;
  const GetMenuUseCase(this._repo);
  FutureResult<List<ProductEntity>> call(String restaurantId) => _repo.getMenu(restaurantId);
}

class GetCategoriesUseCase {
  final RestaurantRepository _repo;
  const GetCategoriesUseCase(this._repo);
  FutureResult<List<CategoryEntity>> call() => _repo.getCategories();
}

class SearchRestaurantsUseCase {
  final RestaurantRepository _repo;
  const SearchRestaurantsUseCase(this._repo);

  FutureResult<List<RestaurantEntity>> call(String query) {
    if (query.trim().length < 2) {
      return Future.value(const Either.right([]));
    }
    return _repo.getRestaurants(RestaurantFilter(search: query.trim()));
  }
}
