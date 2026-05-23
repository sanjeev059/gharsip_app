class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role; // 'customer' | 'admin'
  final List<String> addresses;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'customer',
    this.addresses = const [],
    this.fcmToken,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> m, String uid) => UserModel(
        uid: uid,
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        email: m['email'] ?? '',
        role: m['role'] ?? 'customer',
        addresses: List<String>.from(m['addresses'] ?? []),
        fcmToken: m['fcm_token'],
        createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'addresses': addresses,
        'fcm_token': fcmToken,
        'created_at': createdAt.toIso8601String(),
      };
}
