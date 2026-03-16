import '../../../core/network/api_client.dart';
import '../../../core/error/failures.dart';
import '../../../core/cache/cache_service.dart';
import '../domain/restaurant_domain.dart';

// ═══════════════════════════════════════════════
// MODEL MAPPERS
// ═══════════════════════════════════════════════
extension RestaurantMapper on Map<String, dynamic> {
  RestaurantEntity toRestaurantEntity() => RestaurantEntity(
    id: this['id'],
    name: this['name'],
    logo: this['logo'],
    banner: this['banner'],
    cuisineType: this['cuisine_type'] ?? '',
    address: this['address'] ?? '',
    commune: this['commune'] ?? '',
    lat: (this['lat'] as num).toDouble(),
    lng: (this['lng'] as num).toDouble(),
    rating: (this['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: this['review_count'] ?? 0,
    deliveryTime: this['delivery_time'] ?? 30,
    deliveryFee: (this['delivery_fee'] as num?)?.toDouble() ?? 0,
    minOrder: (this['min_order'] as num?)?.toDouble() ?? 0,
    isOpen: this['is_open'] ?? true,
    isVerified: this['is_verified'] ?? true,
    promoTag: this['promo_tag'],
    distance: (this['distance'] as num?)?.toDouble(),
  );

  CategoryEntity toCategoryEntity() => CategoryEntity(
    id: this['id'],
    name: this['name'],
    emoji: this['emoji'] ?? '🍽️',
    color: this['color'] ?? '#F97316',
    isActive: this['is_active'] ?? true,
    restaurantCount: this['restaurant_count'] ?? 0,
  );

  ProductEntity toProductEntity() => ProductEntity(
    id: this['id'],
    restaurantId: this['restaurant_id'],
    name: this['name'],
    description: this['description'],
    photo: this['photo'],
    price: (this['price'] as num).toDouble(),
    category: this['category'] ?? '',
    isAvailable: this['is_available'] ?? true,
    isFeatured: this['is_featured'] ?? false,
    badge: this['badge'],
    optionGroups: (this['option_groups'] as List? ?? []).map((g) => ProductOptionGroupEntity(
      id: g['id'], name: g['name'],
      required: g['required'] ?? false,
      maxSelections: g['max_selections'] ?? 1,
      options: (g['options'] as List? ?? []).map((o) => ProductOptionEntity(
        id: o['id'], name: o['name'],
        extraPrice: (o['extra_price'] as num?)?.toDouble() ?? 0,
      )).toList(),
    )).toList(),
  );
}

// ═══════════════════════════════════════════════
// REMOTE DATASOURCE
// ═══════════════════════════════════════════════
class RestaurantRemoteDatasource {
  final _dio = ApiClient.instance;

  Future<List<Map<String, dynamic>>> getRestaurants({String? search, String? category, String sortBy = 'rating'}) async {
    final res = await _dio.get('/restaurants', queryParameters: {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
      'sort': sortBy, 'limit': 50,
    });
    return List<Map<String, dynamic>>.from(res.data['restaurants'] as List);
  }

  Future<Map<String, dynamic>> getRestaurantById(String id) async {
    final res = await _dio.get('/restaurants/$id');
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMenu(String restaurantId) async {
    final res = await _dio.get('/restaurants/$restaurantId/menu');
    return List<Map<String, dynamic>>.from(res.data['products'] as List);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _dio.get('/categories');
    return List<Map<String, dynamic>>.from(res.data['categories'] as List);
  }
}

// ═══════════════════════════════════════════════
// MOCK DATASOURCE (dev / offline fallback)
// ═══════════════════════════════════════════════
class RestaurantMockDatasource {
  static final _restaurants = [
    {'id':'r1','name':'Chez Fatima','cuisine_type':'Algérienne','address':'12 Rue de la Paix','commune':'Annaba Centre','lat':36.9065,'lng':7.7335,'rating':4.8,'review_count':342,'delivery_time':25,'delivery_fee':0,'min_order':500,'is_open':true,'is_verified':true,'promo_tag':'Livraison Gratuite','distance':1.2},
    {'id':'r2','name':'Pizza Royale','cuisine_type':'Pizza','address':'45 Av. des Frères Bouadou','commune':'El Bouni','lat':36.890,'lng':7.750,'rating':4.5,'review_count':198,'delivery_time':30,'delivery_fee':150,'min_order':800,'is_open':true,'is_verified':true,'promo_tag':'20% OFF','distance':2.8},
    {'id':'r3','name':'Burger House','cuisine_type':'Burgers','address':'7 Cité 5 Juillet','commune':'El Hadjar','lat':36.870,'lng':7.720,'rating':4.2,'review_count':127,'delivery_time':35,'delivery_fee':200,'min_order':600,'is_open':true,'is_verified':false,'distance':4.1},
    {'id':'r4','name':'Couscous Palace','cuisine_type':'Algérienne','address':'3 Cité 1000 Logts','commune':'Sidi Amar','lat':36.920,'lng':7.760,'rating':4.9,'review_count':521,'delivery_time':40,'delivery_fee':0,'min_order':700,'is_open':true,'is_verified':true,'promo_tag':'Top Noté ⭐','distance':3.5},
    {'id':'r5','name':'Shawarma Express','cuisine_type':'Sandwichs','address':'18 Bd 1er Novembre','commune':'Annaba Centre','lat':36.908,'lng':7.740,'rating':4.3,'review_count':256,'delivery_time':20,'delivery_fee':100,'min_order':400,'is_open':true,'is_verified':true,'promo_tag':'-15%','distance':0.8},
    {'id':'r6','name':'Pâtisserie Ben Youcef','cuisine_type':'Pâtisseries','address':'5 Rue Larbi Ben Mhidi','commune':'Annaba Centre','lat':36.905,'lng':7.748,'rating':4.7,'review_count':89,'delivery_time':15,'delivery_fee':0,'min_order':300,'is_open':true,'is_verified':true,'distance':1.5},
  ];

  static final _categories = [
    {'id':'c1','name':'Algérienne','emoji':'🥘','color':'#F97316','is_active':true,'restaurant_count':12},
    {'id':'c2','name':'Pizza','emoji':'🍕','color':'#EF4444','is_active':true,'restaurant_count':8},
    {'id':'c3','name':'Burgers','emoji':'🍔','color':'#F59E0B','is_active':true,'restaurant_count':6},
    {'id':'c4','name':'Sandwichs','emoji':'🥙','color':'#10B981','is_active':true,'restaurant_count':9},
    {'id':'c5','name':'Sushi','emoji':'🍱','color':'#6366F1','is_active':true,'restaurant_count':2},
    {'id':'c6','name':'Boissons','emoji':'🧃','color':'#06B6D4','is_active':true,'restaurant_count':15},
    {'id':'c7','name':'Pâtisseries','emoji':'🍰','color':'#EC4899','is_active':true,'restaurant_count':5},
    {'id':'c8','name':'Grillades','emoji':'🥩','color':'#84CC16','is_active':true,'restaurant_count':4},
  ];

  static Map<String, List<Map<String, dynamic>>> get _menuByRestaurant => {
    'r1': [
      {'id':'p1','restaurant_id':'r1','name':'Couscous Traditionnel','description':'Couscous aux légumes de saison et agneau mijoté','price':850,'category':'Plats','is_available':true,'is_featured':true,'badge':'⭐ Populaire'},
      {'id':'p2','restaurant_id':'r1','name':'Chorba Frik','description':'Soupe traditionnelle au blé vert et viande','price':350,'category':'Entrées','is_available':true},
      {'id':'p3','restaurant_id':'r1','name':'Chakhchoukha','description':'Plat traditionnel berbère','price':700,'category':'Plats','is_available':true,'is_featured':true},
      {'id':'p4','restaurant_id':'r1','name':'Bourek au Thon','description':'Feuilles de brick farcies','price':200,'category':'Entrées','is_available':true,'badge':'🔥 Recommandé'},
      {'id':'p5','restaurant_id':'r1','name':'Jus Orange Frais','price':200,'category':'Boissons','is_available':true},
      {'id':'p6','restaurant_id':'r1','name':'Zlabia Maison','price':250,'category':'Desserts','is_available':true},
    ],
  };

  List<Map<String, dynamic>> getRestaurants({String? search, String? category, String sortBy = 'rating'}) {
    var list = List<Map<String, dynamic>>.from(_restaurants);
    if (search != null && search.isNotEmpty) {
      list = list.where((r) => (r['name'] as String).toLowerCase().contains(search.toLowerCase())).toList();
    }
    switch (sortBy) {
      case 'distance': list.sort((a, b) => ((a['distance'] as num?) ?? 99).compareTo((b['distance'] as num?) ?? 99));
      case 'delivery_time': list.sort((a, b) => (a['delivery_time'] as int).compareTo(b['delivery_time'] as int));
      default: list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    }
    return list;
  }

  List<Map<String, dynamic>> getCategories() => _categories;

  Map<String, dynamic>? getRestaurantById(String id) =>
      _restaurants.where((r) => r['id'] == id).firstOrNull;

  List<Map<String, dynamic>> getMenu(String restaurantId) =>
      _menuByRestaurant[restaurantId] ?? _menuByRestaurant['r1']!.map((p) => {...p, 'restaurant_id': restaurantId}).toList();
}

// ═══════════════════════════════════════════════
// REPOSITORY IMPLEMENTATION
// ═══════════════════════════════════════════════
class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDatasource _remote;
  final RestaurantMockDatasource _mock = RestaurantMockDatasource();
  final bool _useMock;

  const RestaurantRepositoryImpl({
    required RestaurantRemoteDatasource remote,
    bool useMock = true, // Set false in production
  }) : _remote = remote, _useMock = useMock;

  @override
  FutureResult<List<RestaurantEntity>> getRestaurants(RestaurantFilter filter) => safeCall(() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mock.getRestaurants(
        search: filter.search,
        sortBy: filter.sortBy.name,
      ).map((r) => r.toRestaurantEntity()).toList();
    }
    // Try cache first
    final cached = CacheService.getCachedRestaurants();
    try {
      final data = await _remote.getRestaurants(search: filter.search, sortBy: filter.sortBy.name);
      await CacheService.cacheRestaurants(data);
      return data.map((r) => r.toRestaurantEntity()).toList();
    } catch (e) {
      if (cached != null) return cached.map((r) => r.toRestaurantEntity()).toList();
      rethrow;
    }
  });

  @override
  FutureResult<RestaurantEntity> getRestaurantById(String id) => safeCall(() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final r = _mock.getRestaurantById(id);
      if (r == null) throw const NotFoundFailure(message: 'Restaurant introuvable');
      return r.toRestaurantEntity();
    }
    final cached = CacheService.getCachedRestaurantDetail(id);
    try {
      final data = await _remote.getRestaurantById(id);
      await CacheService.cacheRestaurantDetail(id, data);
      return data.toRestaurantEntity();
    } catch (e) {
      if (cached != null) return cached.toRestaurantEntity();
      rethrow;
    }
  });

  @override
  FutureResult<List<ProductEntity>> getMenu(String restaurantId) => safeCall(() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mock.getMenu(restaurantId).map((p) => p.toProductEntity()).toList();
    }
    final data = await _remote.getMenu(restaurantId);
    return data.map((p) => p.toProductEntity()).toList();
  });

  @override
  FutureResult<List<CategoryEntity>> getCategories() => safeCall(() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mock.getCategories().map((c) => c.toCategoryEntity()).toList();
    }
    final cached = CacheService.getCachedCategories();
    try {
      final data = await _remote.getCategories();
      await CacheService.cacheCategories(data);
      return data.map((c) => c.toCategoryEntity()).toList();
    } catch (_) {
      return cached?.map((c) => c.toCategoryEntity()).toList() ?? [];
    }
  });

  @override
  FutureResult<List<RestaurantEntity>> getFeaturedRestaurants() =>
      getRestaurants(const RestaurantFilter(sortBy: SortOption.rating));

  @override
  FutureResult<List<RestaurantEntity>> getNearbyRestaurants({required double lat, required double lng, double radiusKm = 5}) =>
      getRestaurants(const RestaurantFilter(sortBy: SortOption.distance));
}
