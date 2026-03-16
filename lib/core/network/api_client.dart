import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static Dio? _instance;
  static const _storage = FlutterSecureStorage();

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(dio),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugLog(obj.toString()),
      ),
    ]);

    return dio;
  }

  static void debugLog(String message) {
    // ignore in production
    assert(() {
      print('[WAJBA API] $message');
      return true;
    }());
  }

  static void reset() => _instance = null;
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  static const _storage = FlutterSecureStorage();
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  _AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/')) {
      if (_isRefreshing) {
        _pendingRequests.add(err.requestOptions);
        return;
      }
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
        if (refreshToken == null) {
          _clearAuth();
          handler.next(err);
          return;
        }
        final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
        final newToken = response.data['access_token'];
        await _storage.write(key: AppConstants.tokenKey, value: newToken);

        // Retry original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retried = await _dio.fetch(err.requestOptions);
        handler.resolve(retried);

        // Retry pending
        for (final req in _pendingRequests) {
          req.headers['Authorization'] = 'Bearer $newToken';
          _dio.fetch(req);
        }
        _pendingRequests.clear();
      } catch (_) {
        _clearAuth();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}

// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException({required this.message, this.statusCode, this.code});

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? (data['message'] ?? 'Erreur serveur') : 'Erreur de connexion';
    return ApiException(
      message: message.toString(),
      statusCode: e.response?.statusCode,
      code: data is Map ? data['code'] : null,
    );
  }

  @override
  String toString() => message;
}
