import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../models/booking_model.dart';
import '../models/product_model.dart';
import '../constants/app_strings.dart';

class ApiService {
  static const _base = AppStrings.backendUrl;
  static const _token = AppStrings.adminApiToken;

  static Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // ── Admin: Orders ──────────────────────────────────────────────────────────

  static Future<List<TshirtOrder>> getAllOrders() async {
    final res = await http
        .get(Uri.parse('$_base/api/admin/orders?limit=200'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('Failed to load orders');
    final body = jsonDecode(res.body);
    return (body['orders'] as List<dynamic>? ?? [])
        .map((m) => TshirtOrder.fromBackend(Map<String, dynamic>.from(m)))
        .toList();
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    await http
        .patch(Uri.parse('$_base/api/admin/orders/$orderId'), headers: _adminHeaders, body: jsonEncode({'status': status}))
        .timeout(const Duration(seconds: 20));
  }

  // ── Admin: Bookings ────────────────────────────────────────────────────────

  static Future<List<SareeBooking>> getAllBookings() async {
    final res = await http
        .get(Uri.parse('$_base/api/admin/bookings?limit=200'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('Failed to load bookings');
    final body = jsonDecode(res.body);
    return (body['bookings'] as List<dynamic>? ?? [])
        .map((m) => SareeBooking.fromBackend(Map<String, dynamic>.from(m)))
        .toList();
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    await http
        .patch(Uri.parse('$_base/api/admin/bookings/$bookingId'), headers: _adminHeaders, body: jsonEncode({'status': status}))
        .timeout(const Duration(seconds: 20));
  }

  // ── Admin: Stats ───────────────────────────────────────────────────────────

  static Future<Map<String, int>> getAdminStats() async {
    final res = await http
        .get(Uri.parse('$_base/api/admin/stats'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return {};
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  // ── Admin: Products ────────────────────────────────────────────────────────

  static Future<List<ProductModel>> getProducts({bool? active}) async {
    final q = active != null ? '?active=$active' : '';
    final res = await http
        .get(Uri.parse('$_base/api/products$q'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return [];
    final list = (jsonDecode(res.body)['products'] as List? ?? []);
    return list.map((m) => ProductModel.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  static Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final res = await http
        .post(Uri.parse('$_base/api/products'), headers: _adminHeaders, body: jsonEncode(data))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('Failed to create: ${res.body}');
    return ProductModel.fromMap(Map<String, dynamic>.from(jsonDecode(res.body)));
  }

  static Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    final res = await http
        .patch(Uri.parse('$_base/api/products/$id'), headers: _adminHeaders, body: jsonEncode(data))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw Exception('Failed to update: ${res.body}');
  }

  static Future<void> deleteProduct(String id) async {
    await http
        .delete(Uri.parse('$_base/api/products/$id'), headers: _adminHeaders)
        .timeout(const Duration(seconds: 20));
  }

  static Future<String> uploadImage(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_base/api/products/upload-image'));
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final body = jsonDecode(await streamed.stream.bytesToString());
    if (streamed.statusCode != 200) throw Exception('Upload failed: ${body['detail'] ?? body}');
    return body['url'] as String;
  }

  // ── Customer: Bookings ─────────────────────────────────────────────────────

  static Future<String> createBooking({
    required String userId, required String email, required String name,
    required String phone, required String address, required String pincode,
    required List<String> services, required DateTime pickupDate,
    required String timeSlot, String notes = '',
  }) async {
    final res = await http
        .post(Uri.parse('$_base/api/bookings'), headers: _headers,
            body: jsonEncode({'userId': userId, 'email': email, 'name': name, 'phone': phone,
              'address': address, 'pincode': pincode, 'services': services,
              'pickupDate': pickupDate.toIso8601String(), 'timeSlot': timeSlot, 'notes': notes}))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw Exception('Failed to create booking');
    return jsonDecode(res.body)['id'] ?? '';
  }

  static Future<List<SareeBooking>> getUserBookings(String email) async {
    final res = await http
        .get(Uri.parse('$_base/api/bookings?email=${Uri.encodeComponent(email)}'), headers: _headers)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return [];
    return (jsonDecode(res.body)['bookings'] as List<dynamic>? ?? [])
        .map((m) => SareeBooking.fromBackend(Map<String, dynamic>.from(m)))
        .toList();
  }

  // ── Customer: Orders ───────────────────────────────────────────────────────

  static Future<List<TshirtOrder>> getUserOrders(String email) async {
    final res = await http
        .get(Uri.parse('$_base/api/orders?email=${Uri.encodeComponent(email)}'), headers: _headers)
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return [];
    return (jsonDecode(res.body)['orders'] as List<dynamic>? ?? [])
        .map((m) => TshirtOrder.fromBackend(Map<String, dynamic>.from(m)))
        .toList();
  }
}
