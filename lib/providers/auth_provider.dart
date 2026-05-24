import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  UserModel? _user;
  bool _loading = true;
  String? _pendingEmail;

  UserModel? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = await _service.getLoggedInUser();
    _loading = false;
    notifyListeners();
  }

  Future<void> sendOtp({
    required String email,
    required void Function() onSent,
    required void Function(String) onError,
  }) async {
    _pendingEmail = email.trim().toLowerCase();
    await _service.sendOtp(email: _pendingEmail!, onSent: onSent, onError: onError);
  }

  Future<bool> verifyOtp({
    required String otp,
    required void Function(String) onError,
  }) async {
    if (_pendingEmail == null) {
      onError('Please request OTP first');
      return false;
    }
    try {
      final u = await _service.verifyOtp(email: _pendingEmail!, otp: otp);
      if (u == null) {
        onError('Invalid or expired OTP. Please try again.');
        return false;
      }
      _user = u;
      notifyListeners();
      return true;
    } catch (e) {
      onError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    if (_user == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    await _service.updateUser(_user!.uid, data);
    _user = UserModel(
      uid: _user!.uid,
      name: name ?? _user!.name,
      phone: phone ?? _user!.phone,
      email: _user!.email,
      role: _user!.role,
      createdAt: _user!.createdAt,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _pendingEmail = null;
    notifyListeners();
  }
}
