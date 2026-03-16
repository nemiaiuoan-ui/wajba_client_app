import 'package:dio/dio.dart';

// ═══════════════════════════════════════════════
// EITHER TYPE — Left = Failure, Right = Success
// ═══════════════════════════════════════════════
class Either<L, R> {
  final L? _left;
  final R? _right;
  final bool _isRight;

  const Either.left(L value) : _left = value, _right = null, _isRight = false;
  const Either.right(R value) : _left = null, _right = value, _isRight = true;

  bool get isRight => _isRight;
  bool get isLeft => !_isRight;
  L get left => _left as L;
  R get right => _right as R;

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) =>
      _isRight ? onRight(_right as R) : onLeft(_left as L);

  Either<L, T> map<T>(T Function(R) f) =>
      _isRight ? Either.right(f(_right as R)) : Either.left(_left as L);
}

typedef Result<T> = Either<Failure, T>;
typedef FutureResult<T> = Future<Either<Failure, T>>;

// ═══════════════════════════════════════════════
// FAILURE HIERARCHY
// ═══════════════════════════════════════════════
abstract class Failure {
  final String message;
  final String? code;
  const Failure({required this.message, this.code});

  @override
  String toString() => message;
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Vérifiez votre connexion internet', super.code = 'NETWORK_ERROR'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Délai de connexion dépassé', super.code = 'TIMEOUT'});
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code = 'AUTH_ERROR'});
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure({super.message = 'Code OTP incorrect ou expiré', super.code = 'INVALID_OTP'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expirée, veuillez vous reconnecter', super.code = 'UNAUTHORIZED'});
}

// Server Failures
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode, super.code = 'SERVER_ERROR'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Ressource introuvable', super.code = 'NOT_FOUND'});
}

// Business Failures
class CartFailure extends Failure {
  const CartFailure({required super.message, super.code = 'CART_ERROR'});
}

class OrderFailure extends Failure {
  const OrderFailure({required super.message, super.code = 'ORDER_ERROR'});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code = 'LOCATION_ERROR'});
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Erreur de cache local', super.code = 'CACHE_ERROR'});
}

// Unknown
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Une erreur inattendue s\'est produite', super.code = 'UNKNOWN'});
}

// ═══════════════════════════════════════════════
// ERROR HANDLER — Convert exceptions to Failures
// ═══════════════════════════════════════════════
class ErrorHandler {
  static Failure handle(Object error, [StackTrace? st]) {
    if (error is Failure) return error;

    if (error is DioException) return _handleDio(error);

    if (error is FormatException) {
      return const ServerFailure(message: 'Données invalides reçues du serveur');
    }

    return const UnknownFailure();
  }

  static Failure _handleDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? 'Erreur serveur') : 'Erreur serveur';
        final code = data is Map ? data['code'] : null;

        if (status == 401) return UnauthorizedFailure(message: msg.toString());
        if (status == 404) return NotFoundFailure(message: msg.toString());
        if (status == 422) return ServerFailure(message: msg.toString(), statusCode: status, code: code?.toString());

        return ServerFailure(message: msg.toString(), statusCode: status, code: code?.toString());

      default:
        return const NetworkFailure();
    }
  }
}

// ═══════════════════════════════════════════════
// SAFE CALL WRAPPER
// ═══════════════════════════════════════════════
Future<Result<T>> safeCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Either.right(result);
  } catch (e, st) {
    return Either.left(ErrorHandler.handle(e, st));
  }
}
