import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  // Send OTP via Firebase Phone Auth
  Future<void> sendOtp({
    required String phone,
    required void Function(PhoneAuthCredential) onAutoVerified,
    required void Function(String verId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP and sign in
  Future<UserModel?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;

    // Check or create Firestore user doc
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      final phone = user.phoneNumber ?? '';
      final isAdmin = phone == AppStrings.adminPhone;
      final model = UserModel(
        uid: user.uid,
        name: '',
        phone: phone,
        email: '',
        role: isAdmin ? 'admin' : 'customer',
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(model.toMap());
      return model;
    }
    return UserModel.fromMap(doc.data()!, user.uid);
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _db.collection('users').doc(uid).update(data);

  Future<void> signOut() => _auth.signOut();
}
