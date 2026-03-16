import '../../../core/error/failures.dart';

// ═══════════════════════════════════════════════
// ENTITIES (pure business objects, no JSON)
// ═══════════════════════════════════════════════
class UserEntity {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.isActive = true,
    required this.createdAt,
  });

  UserEntity copyWith({String? name, String? email, String? avatar}) => UserEntity(
    id: id, phone: phone, isActive: isActive, createdAt: createdAt,
    name: name ?? this.name,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
  );

  String get displayName => name.isNotEmpty ? name : phone;
  String get initials => name.isNotEmpty ? name[0].toUpperCase() : phone[0];
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  const AuthTokens({required this.accessToken, required this.refreshToken});
}

class LoginResult {
  final UserEntity user;
  final AuthTokens tokens;
  const LoginResult({required this.user, required this.tokens});
}

// ═══════════════════════════════════════════════
// REPOSITORY INTERFACE
// ═══════════════════════════════════════════════
abstract class AuthRepository {
  FutureResult<void> sendOtp(String phone);
  FutureResult<LoginResult> verifyOtp({required String phone, required String otp, String? name});
  FutureResult<UserEntity> getMe();
  FutureResult<UserEntity> updateProfile({String? name, String? email, String? avatar});
  FutureResult<void> logout();
  Future<bool> get isLoggedIn;
}

// ═══════════════════════════════════════════════
// USE CASES
// ═══════════════════════════════════════════════
class SendOtpUseCase {
  final AuthRepository _repository;
  const SendOtpUseCase(this._repository);

  FutureResult<void> call(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '');
    if (!RegExp(r'^(05|06|07)\d{8}$').hasMatch(cleaned)) {
      return Future.value(Either.left(const AuthFailure(message: 'Numéro de téléphone invalide (format: 06XXXXXXXX)')));
    }
    return _repository.sendOtp(cleaned);
  }
}

class VerifyOtpUseCase {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  FutureResult<LoginResult> call({required String phone, required String otp, String? name}) {
    if (otp.length != 4 || !RegExp(r'^\d{4}$').hasMatch(otp)) {
      return Future.value(Either.left(const InvalidOtpFailure()));
    }
    return _repository.verifyOtp(phone: phone, otp: otp, name: name);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);
  FutureResult<UserEntity> call() => _repository.getMe();
}

class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);
  FutureResult<void> call() => _repository.logout();
}

class UpdateProfileUseCase {
  final AuthRepository _repository;
  const UpdateProfileUseCase(this._repository);

  FutureResult<UserEntity> call({String? name, String? email, String? avatar}) {
    if (name != null && name.trim().length < 2) {
      return Future.value(Either.left(const AuthFailure(message: 'Le nom doit contenir au moins 2 caractères')));
    }
    if (email != null && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Future.value(Either.left(const AuthFailure(message: 'Adresse email invalide')));
    }
    return _repository.updateProfile(name: name, email: email, avatar: avatar);
  }
}
