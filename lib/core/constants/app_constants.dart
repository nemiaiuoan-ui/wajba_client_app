class AppConstants {
  // API
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String wsUrl = 'ws://localhost:3000';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_done';
  static const String selectedAddressKey = 'selected_address';

  // App
  static const String appName = 'WAJBA';
  static const String currency = 'DZD';
  static const String currencySymbol = 'دج';

  // Map
  static const double defaultLat = 36.9065;   // Annaba
  static const double defaultLng = 7.7335;
  static const double mapZoom = 14.0;
  static const double searchRadius = 5000.0;   // 5km

  // Pagination
  static const int pageSize = 20;

  // OTP
  static const int otpLength = 4;
  static const int otpExpiry = 120; // secondes

  // Cart
  static const int maxItemQuantity = 20;

  // Rating
  static const int maxRating = 5;
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String main = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String restaurant = '/restaurant/:id';
  static const String product = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirm = '/order-confirm/:id';
  static const String tracking = '/tracking/:id';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String notifications = '/notifications';
  static const String support = '/support';
}
