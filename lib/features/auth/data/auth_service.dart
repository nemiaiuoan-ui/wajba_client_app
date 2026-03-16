import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/models.dart';

class AuthService {
  final _dio = ApiClient.instance;
  static const _storage = FlutterSecureStorage();

  // Étape 1: Envoyer OTP
  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post('/auth/register', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Étape 2: Vérifier OTP + connexion
  Future<UserModel> verifyOtp({required String phone, required String otp, String? name}) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': otp,
        if (name != null) 'name': name,
      });
      final data = response.data;
      await _saveTokens(data['access_token'], data['refresh_token']);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Connexion directe (si déjà inscrit)
  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      final data = response.data;
      await _saveTokens(data['access_token'], data['refresh_token']);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token == null) return null;
      final response = await _dio.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<bool> get isLoggedIn async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}
