import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';

class AuthService {
  static const _prefKey = 'gharsip_user_email';
  static const _base = AppStrings.backendUrl;

  Future<String?> get savedEmail async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  Future<void> sendOtp({
    required String email,
    required void Function() onSent,
    required void Function(String) onError,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/api/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      ).timeout(const Duration(seconds: 60));

      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        onSent();
      } else {
        onError(body['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        onError('Server is starting up, please try again in 30 seconds.');
      } else {
        onError('Network error. Check your connection.');
      }
    }
  }

  Future<UserModel?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    // 1. Verify OTP with backend
    final res = await http.post(
      Uri.parse('$_base/api/otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim().toLowerCase(), 'otp': otp}),
    ).timeout(const Duration(seconds: 60));

    final body = jsonDecode(res.body);
    if (body['success'] != true) return null;

    final cleanEmail = email.trim().toLowerCase();
    final uid = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    // Role is always determined by the backend — admin email list lives server-side
    final seedRole = cleanEmail == AppStrings.adminEmail ? 'admin' : 'customer';

    // 2. Upsert user in MongoDB via backend
    final userRes = await http.post(
      Uri.parse('$_base/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'email': cleanEmail,
        'name': '',
        'phone': '',
        'role': seedRole,
      }),
    ).timeout(const Duration(seconds: 30));

    final userBody = jsonDecode(userRes.body);

    // 3. Save email locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, cleanEmail);

    // Use role from backend response — backend is the source of truth
    return UserModel(
      uid: userBody['uid'] ?? uid,
      name: userBody['name'] ?? '',
      phone: userBody['phone'] ?? '',
      email: cleanEmail,
      role: userBody['role'] ?? seedRole,
      createdAt: DateTime.tryParse(userBody['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Future<UserModel?> getLoggedInUser() async {
    final email = await savedEmail;
    if (email == null) return null;
    final uid = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    try {
      final res = await http.get(
        Uri.parse('$_base/api/users/$uid'),
      ).timeout(const Duration(seconds: 30));

      if (res.statusCode == 404) return null;
      final body = jsonDecode(res.body);
      return UserModel(
        uid: body['uid'] ?? uid,
        name: body['name'] ?? '',
        phone: body['phone'] ?? '',
        email: email,
        role: body['role'] ?? 'customer',
        createdAt: DateTime.tryParse(body['createdAt'] ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      // Offline — return minimal user from saved email
      return UserModel(
        uid: uid,
        name: '',
        phone: '',
        email: email,
        role: email == AppStrings.adminEmail ? 'admin' : 'customer',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await http.patch(
      Uri.parse('$_base/api/users/$uid'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 30));
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
