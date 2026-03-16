import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/error/failures.dart';
import '../../../core/cache/cache_service.dart';
import '../domain/auth_domain.dart';

// ═══════════════════════════════════════════════
// DATA MODEL (JSON → Entity conversion)
// ═══════════════════════════════════════════════
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.avatar,
    super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'] ?? '',
    phone: json['phone'],
    email: json['email'],
    avatar: json['avatar'],
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone,
    'email': email, 'avatar': avatar,
    'is_active': isActive, 'created_at': createdAt.toIso8601String(),
  };
}

// ═══════════════════════════════════════════════
// REMOTE DATASOURCE
// ═══════════════════════════════════════════════
abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> sendOtp(String phone);
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, String? name});
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> updateProfile({String? name, String? email, String? avatar});
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final _dio = ApiClient.instance;

  @override
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await _dio.post('/auth/register', data: {'phone': phone});
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({required String phone, required String otp, String? name}) async {
    final res = await _dio.post('/auth/verify-otp', data: {
      'phone': phone, 'otp': otp,
      if (name != null) 'name': name,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({String? name, String? email, String? avatar}) async {
    final res = await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (avatar != null) 'avatar': avatar,
    });
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    try { await _dio.post('/auth/logout'); } catch (_) {}
  }
}

// ═══════════════════════════════════════════════
// LOCAL DATASOURCE
// ═══════════════════════════════════════════════
class AuthLocalDatasource {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'wajba_access_token';
  static const _refreshKey = 'wajba_refresh_token';

  Future<void> saveTokens(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> get hasToken async {
    final t = await _storage.read(key: _tokenKey);
    return t != null;
  }

  Future<void> cacheUser(Map<String, dynamic> user) => CacheService.cacheUser(user);
  Map<String, dynamic>? getCachedUser() => CacheService.getCachedUser();
}

// ═══════════════════════════════════════════════
// REPOSITORY IMPLEMENTATION
// ═══════════════════════════════════════════════
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  const AuthRepositoryImpl({required AuthRemoteDatasource remote, required AuthLocalDatasource local})
      : _remote = remote, _local = local;

  @override
  FutureResult<void> sendOtp(String phone) => safeCall(() => _remote.sendOtp(phone));

  @override
  FutureResult<LoginResult> verifyOtp({required String phone, required String otp, String? name}) =>
      safeCall(() async {
        final data = await _remote.verifyOtp(phone: phone, otp: otp, name: name);
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final tokens = AuthTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        await _local.saveTokens(tokens.accessToken, tokens.refreshToken);
        await _local.cacheUser(user.toJson());
        return LoginResult(user: user, tokens: tokens);
      });

  @override
  FutureResult<UserEntity> getMe() => safeCall(() async {
    // Try cache first (offline support)
    final cached = _local.getCachedUser();
    try {
      final data = await _remote.getMe();
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _local.cacheUser(user.toJson());
      return user;
    } catch (e) {
      if (cached != null) return UserModel.fromJson(cached);
      rethrow;
    }
  });

  @override
  FutureResult<UserEntity> updateProfile({String? name, String? email, String? avatar}) =>
      safeCall(() async {
        final data = await _remote.updateProfile(name: name, email: email, avatar: avatar);
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _local.cacheUser(user.toJson());
        return user;
      });

  @override
  FutureResult<void> logout() => safeCall(() async {
    await _remote.logout();
    await _local.clearTokens();
    await CacheService.clearAll();
  });

  @override
  Future<bool> get isLoggedIn => _local.hasToken;
}
