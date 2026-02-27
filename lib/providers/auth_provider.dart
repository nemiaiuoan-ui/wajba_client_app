import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User?      _firebaseUser;
  UserModel? _user;
  bool       _isLoading    = false;
  String     _error        = '';
  String     _verificationId = '';

  bool       get isLoggedIn  => _firebaseUser != null;
  bool       get isLoading   => _isLoading;
  String     get error       => _error;
  UserModel? get user        => _user;
  String     get uid         => _firebaseUser?.uid ?? '';

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadUser(user.uid);
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(uid, doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // ── ÉTAPE 1 : Envoyer SMS OTP ──────────────────────────────────
  Future<bool> sendOtp(String phone) async {
    _setLoading(true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(cred);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_mapAuthError(e.code));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      _setError('Erreur envoi SMS: $e');
      return false;
    }
  }

  // ── ÉTAPE 2 : Vérifier OTP ─────────────────────────────────────
  Future<bool> verifyOtp(String smsCode) async {
    _setLoading(true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(cred);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      return false;
    }
  }

  // ── ÉTAPE 3 : Compléter le profil ─────────────────────────────
  Future<bool> completeProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    if (_firebaseUser == null) return false;
    _setLoading(true);
    try {
      final newUser = UserModel(
        uid:       _firebaseUser!.uid,
        name:      name,
        phone:     _firebaseUser!.phoneNumber ?? '',
        email:     email,
        address:   address,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(_firebaseUser!.uid).set(newUser.toMap());
      _user = newUser;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Erreur sauvegarde profil: $e');
      return false;
    }
  }

  Future<bool> updateProfile(UserModel updated) async {
    _setLoading(true);
    try {
      await _db.collection('users').doc(uid).update(updated.toMap());
      _user = updated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur mise à jour: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-phone-number':  return 'Numéro de téléphone invalide';
      case 'invalid-verification-code': return 'Code OTP incorrect';
      case 'session-expired':       return 'Session expirée, renvoyez le code';
      case 'too-many-requests':     return 'Trop de tentatives, réessayez plus tard';
      default: return 'Erreur d\'authentification ($code)';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _error = '';
    notifyListeners();
  }

  void _setError(String e) {
    _error = e;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
