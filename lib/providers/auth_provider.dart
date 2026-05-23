import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _user;
  bool _loading = true;
  String? _verificationId;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _service.authState.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await _service.getUser(firebaseUser.uid);
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> sendOtp({
    required String phone,
    required void Function() onSent,
    required void Function(String) onError,
  }) async {
    await _service.sendOtp(
      phone: phone,
      onAutoVerified: (credential) async {
        final u = await _service.verifyOtp(
          verificationId: credential.verificationId ?? '',
          smsCode: credential.smsCode ?? '',
        );
        _user = u;
        notifyListeners();
      },
      onCodeSent: (verId, _) {
        _verificationId = verId;
        onSent();
      },
      onFailed: (e) => onError(e.message ?? 'OTP failed'),
    );
  }

  Future<bool> verifyOtp({
    required String otp,
    required void Function(String) onError,
  }) async {
    if (_verificationId == null) {
      onError('Please request OTP first');
      return false;
    }
    try {
      final u = await _service.verifyOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      if (u == null) {
        onError('Verification failed');
        return false;
      }
      _user = u;
      notifyListeners();
      return true;
    } catch (e) {
      onError('Invalid OTP. Please try again.');
      return false;
    }
  }

  Future<void> updateProfile({String? name, String? email}) async {
    if (_user == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    await _service.updateUser(_user!.uid, data);
    _user = UserModel(
      uid: _user!.uid,
      name: name ?? _user!.name,
      phone: _user!.phone,
      email: email ?? _user!.email,
      role: _user!.role,
      createdAt: _user!.createdAt,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }
}
