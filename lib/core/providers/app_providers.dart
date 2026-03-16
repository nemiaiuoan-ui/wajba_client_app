import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/failures.dart';
import '../services/websocket_service.dart';
import '../../features/auth/domain/auth_domain.dart';
import '../../features/auth/data/auth_data.dart';
import '../../features/cart/domain/cart_domain.dart';
import '../../features/cart/data/cart_repository_impl.dart';
import '../../features/order/domain/order_domain.dart';
import '../../features/restaurant/domain/restaurant_domain.dart';
import '../../features/restaurant/data/restaurant_data.dart';

// ═══════════════════════════════════════════════
// DI — Repository + UseCase providers
// ═══════════════════════════════════════════════

// Auth
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(
  remote: AuthRemoteDatasourceImpl(),
  local: AuthLocalDatasource(),
));
final sendOtpUseCaseProvider = Provider((ref) => SendOtpUseCase(ref.read(authRepositoryProvider)));
final verifyOtpUseCaseProvider = Provider((ref) => VerifyOtpUseCase(ref.read(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.read(authRepositoryProvider)));
final updateProfileUseCaseProvider = Provider((ref) => UpdateProfileUseCase(ref.read(authRepositoryProvider)));

// Cart
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final repo = CartRepositoryImpl();
  ref.onDispose(repo.dispose);
  return repo;
});
final addToCartUseCaseProvider = Provider((ref) => AddToCartUseCase(ref.read(cartRepositoryProvider)));
final applyPromoUseCaseProvider = Provider((ref) => ApplyPromoUseCase(ref.read(cartRepositoryProvider)));

// Restaurant
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) =>
    RestaurantRepositoryImpl(remote: RestaurantRemoteDatasource(), useMock: true));
final getRestaurantsUseCaseProvider = Provider((ref) => GetRestaurantsUseCase(ref.read(restaurantRepositoryProvider)));
final getRestaurantDetailUseCaseProvider = Provider((ref) => GetRestaurantDetailUseCase(ref.read(restaurantRepositoryProvider)));
final getMenuUseCaseProvider = Provider((ref) => GetMenuUseCase(ref.read(restaurantRepositoryProvider)));
final getCategoriesUseCaseProvider = Provider((ref) => GetCategoriesUseCase(ref.read(restaurantRepositoryProvider)));
final searchUseCaseProvider = Provider((ref) => SearchRestaurantsUseCase(ref.read(restaurantRepositoryProvider)));

// ═══════════════════════════════════════════════
// AUTH NOTIFIER
// ═══════════════════════════════════════════════
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final Failure? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;
  AuthState copyWith({UserEntity? user, bool? isLoading, Failure? error}) =>
      AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);
  AuthState loading() => AuthState(user: user, isLoading: true);
  AuthState withError(Failure f) => AuthState(user: user, error: f);
  AuthState withUser(UserEntity u) => AuthState(user: u);
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _tryAutoLogin();
    return const AuthState(isLoading: true);
  }

  Future<void> _tryAutoLogin() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getMe();
    result.fold(
      (f) => state = const AuthState(),
      (user) => state = AuthState(user: user),
    );
  }

  Future<bool> sendOtp(String phone) async {
    state = state.loading();
    final result = await ref.read(sendOtpUseCaseProvider).call(phone);
    return result.fold(
      (f) { state = state.withError(f); return false; },
      (_) { state = AuthState(isLoading: false); return true; },
    );
  }

  Future<bool> verifyOtp({required String phone, required String otp, String? name}) async {
    state = state.loading();
    final result = await ref.read(verifyOtpUseCaseProvider).call(phone: phone, otp: otp, name: name);
    return result.fold(
      (f) { state = state.withError(f); return false; },
      (loginResult) {
        state = AuthState(user: loginResult.user);
        // Connect WebSocket
        ref.read(wsServiceProvider).connect(loginResult.tokens.accessToken);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.loading();
    await ref.read(logoutUseCaseProvider).call();
    ref.read(wsServiceProvider).disconnect();
    ref.read(cartNotifierProvider.notifier).clear();
    state = const AuthState();
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    state = state.loading();
    final result = await ref.read(updateProfileUseCaseProvider).call(name: name, email: email);
    return result.fold(
      (f) { state = AuthState(user: state.user, error: f); return false; },
      (user) { state = AuthState(user: user); return true; },
    );
  }

  void clearError() => state = AuthState(user: state.user);
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
final currentUserProvider = Provider((ref) => ref.watch(authNotifierProvider).user);
final isLoggedInProvider = Provider((ref) => ref.watch(authNotifierProvider).isLoggedIn);

// ═══════════════════════════════════════════════
// CART NOTIFIER
// ═══════════════════════════════════════════════
class CartNotifier extends Notifier<CartEntity> {
  @override
  CartEntity build() => ref.read(cartRepositoryProvider).getCart();

  Future<Result<CartEntity>> addItem(CartItemEntity item, {bool Function()? onNewRestaurant}) async {
    final useCase = ref.read(addToCartUseCaseProvider);
    final result = await useCase.call(
      item: item,
      currentCart: state,
      askClearConfirmation: onNewRestaurant ?? () => false,
    );
    result.fold((_) {}, (cart) => state = cart);
    return result;
  }

  Future<void> removeItem(String productId) async {
    final result = await ref.read(cartRepositoryProvider).removeItem(productId);
    result.fold((_) {}, (cart) => state = cart);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final result = await ref.read(cartRepositoryProvider).updateQuantity(productId, quantity);
    result.fold((_) {}, (cart) => state = cart);
  }

  Future<Result<CartEntity>> applyPromo(String code) async {
    final result = await ref.read(applyPromoUseCaseProvider).call(code, state);
    result.fold((_) {}, (cart) => state = cart);
    return result;
  }

  Future<void> removePromo() async {
    await ref.read(cartRepositoryProvider).removePromoCode();
    final updated = ref.read(cartRepositoryProvider).getCart();
    state = updated;
  }

  Future<void> setDeliveryFee(double fee) async {
    final result = await ref.read(cartRepositoryProvider).setDeliveryFee(fee);
    result.fold((_) {}, (cart) => state = cart);
  }

  void clear() {
    ref.read(cartRepositoryProvider).clearCart();
    state = CartEntity.empty;
  }
}

final cartNotifierProvider = NotifierProvider<CartNotifier, CartEntity>(() => CartNotifier());
final cartCountProvider = Provider((ref) => ref.watch(cartNotifierProvider).totalItems);
final cartTotalProvider = Provider((ref) => ref.watch(cartNotifierProvider).total);

// ═══════════════════════════════════════════════
// RESTAURANT PROVIDERS
// ═══════════════════════════════════════════════
final restaurantFilterProvider = StateProvider((ref) => const RestaurantFilter());

final restaurantsProvider = FutureProvider.family<List<RestaurantEntity>, RestaurantFilter>((ref, filter) async {
  final result = await ref.read(getRestaurantsUseCaseProvider).call(filter);
  return result.fold((f) => throw f, (r) => r);
});

final restaurantDetailProvider = FutureProvider.family<RestaurantEntity, String>((ref, id) async {
  final result = await ref.read(getRestaurantDetailUseCaseProvider).call(id);
  return result.fold((f) => throw f, (r) => r);
});

final restaurantMenuProvider = FutureProvider.family<List<ProductEntity>, String>((ref, restaurantId) async {
  final result = await ref.read(getMenuUseCaseProvider).call(restaurantId);
  return result.fold((f) => throw f, (r) => r);
});

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final result = await ref.read(getCategoriesUseCaseProvider).call();
  return result.fold((f) => throw f, (r) => r);
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final searchResultsProvider = FutureProvider<List<RestaurantEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return [];
  final result = await ref.read(searchUseCaseProvider).call(query);
  return result.fold((f) => throw f, (r) => r);
});

// ═══════════════════════════════════════════════
// TRACKING NOTIFIER — Real WebSocket GPS
// ═══════════════════════════════════════════════
class TrackingState {
  final String orderId;
  final double? driverLat;
  final double? driverLng;
  final double? driverHeading;
  final OrderStatus status;
  final int? etaMinutes;
  final bool isConnected;

  const TrackingState({
    required this.orderId,
    this.driverLat, this.driverLng, this.driverHeading,
    this.status = OrderStatus.preparing,
    this.etaMinutes,
    this.isConnected = false,
  });

  TrackingState copyWith({
    double? driverLat, double? driverLng, double? driverHeading,
    OrderStatus? status, int? etaMinutes, bool? isConnected,
  }) => TrackingState(
    orderId: orderId,
    driverLat: driverLat ?? this.driverLat,
    driverLng: driverLng ?? this.driverLng,
    driverHeading: driverHeading ?? this.driverHeading,
    status: status ?? this.status,
    etaMinutes: etaMinutes ?? this.etaMinutes,
    isConnected: isConnected ?? this.isConnected,
  );
}

class TrackingNotifier extends FamilyNotifier<TrackingState, String> {
  StreamSubscription? _locationSub;
  StreamSubscription? _statusSub;

  @override
  TrackingState build(String orderId) {
    _subscribe(orderId);
    ref.onDispose(_cleanup);
    return TrackingState(orderId: orderId);
  }

  void _subscribe(String orderId) {
    final ws = ref.read(wsServiceProvider);
    ws.subscribeToOrder(orderId);

    _locationSub = ws.driverLocations
        .where((loc) => loc.orderId == orderId)
        .listen((loc) {
          state = state.copyWith(
            driverLat: loc.lat,
            driverLng: loc.lng,
            driverHeading: loc.heading,
            isConnected: true,
          );
        });

    _statusSub = ws.orderUpdates
        .where((data) => data['order_id'] == orderId)
        .listen((data) {
          final statusStr = data['status'] as String? ?? '';
          final status = OrderStatus.values.firstWhere(
            (s) => s.name == statusStr,
            orElse: () => state.status,
          );
          state = state.copyWith(
            status: status,
            etaMinutes: data['eta_minutes'] as int?,
          );
        });
  }

  void _cleanup() {
    _locationSub?.cancel();
    _statusSub?.cancel();
    ref.read(wsServiceProvider).unsubscribeFromOrder(arg);
  }
}

final trackingProvider = NotifierProvider.family<TrackingNotifier, TrackingState, String>(
  () => TrackingNotifier(),
);

// ═══════════════════════════════════════════════
// SELECTED ADDRESS PROVIDER
// ═══════════════════════════════════════════════
final selectedAddressProvider = StateProvider<AddressEntity?>((ref) => null);

// ═══════════════════════════════════════════════
// CONNECTIVITY PROVIDER
// ═══════════════════════════════════════════════
final isOnlineProvider = StateProvider<bool>((ref) => true);
