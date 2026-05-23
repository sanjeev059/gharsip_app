import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/booking_model.dart';
import '../models/design_model.dart';
import '../models/cart_item.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Designs ───────────────────────────────────────────────────────────────

  Stream<List<DesignModel>> designs() => _db
      .collection('designs')
      .where('is_active', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => DesignModel.fromMap(d.data(), d.id)).toList());

  // ── T-shirt orders ────────────────────────────────────────────────────────

  Future<String> createTshirtOrder({
    required String userId,
    required String phone,
    required String name,
    required List<CartItem> items,
    required int subtotal,
    required int delivery,
    required int total,
    required String address,
  }) async {
    final ref = await _db.collection('tshirt_orders').add({
      'user_id': userId,
      'phone': phone,
      'name': name,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'delivery': delivery,
      'total': total,
      'address': address,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
    return ref.id;
  }

  Stream<List<TshirtOrder>> userOrders(String uid) => _db
      .collection('tshirt_orders')
      .where('user_id', isEqualTo: uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TshirtOrder.fromMap(d.data(), d.id)).toList());

  Stream<List<TshirtOrder>> allOrders() => _db
      .collection('tshirt_orders')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TshirtOrder.fromMap(d.data(), d.id)).toList());

  Future<void> updateOrderStatus(String orderId, String status) =>
      _db.collection('tshirt_orders').doc(orderId).update({'status': status});

  // ── Saree bookings ────────────────────────────────────────────────────────

  Future<String> createBooking({
    required String userId,
    required String phone,
    required String name,
    required List<String> services,
    required DateTime pickupDate,
    required String timeSlot,
    required String address,
    required String pincode,
    String notes = '',
  }) async {
    final ref = await _db.collection('saree_bookings').add({
      'user_id': userId,
      'phone': phone,
      'name': name,
      'services': services,
      'pickup_date': pickupDate.toIso8601String(),
      'time_slot': timeSlot,
      'address': address,
      'pincode': pincode,
      'notes': notes,
      'status': 'new',
      'created_at': DateTime.now().toIso8601String(),
    });
    return ref.id;
  }

  Stream<List<SareeBooking>> userBookings(String uid) => _db
      .collection('saree_bookings')
      .where('user_id', isEqualTo: uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => SareeBooking.fromMap(d.data(), d.id)).toList());

  Stream<List<SareeBooking>> allBookings() => _db
      .collection('saree_bookings')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => SareeBooking.fromMap(d.data(), d.id)).toList());

  Future<void> updateBookingStatus(String bookingId, String status) =>
      _db.collection('saree_bookings').doc(bookingId).update({'status': status});

  // ── Admin stats ───────────────────────────────────────────────────────────

  Future<Map<String, int>> todayStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final orders = await _db
        .collection('tshirt_orders')
        .where('created_at', isGreaterThanOrEqualTo: start)
        .where('created_at', isLessThanOrEqualTo: end)
        .get();

    final bookings = await _db
        .collection('saree_bookings')
        .where('created_at', isGreaterThanOrEqualTo: start)
        .where('created_at', isLessThanOrEqualTo: end)
        .get();

    final pendingOrders = await _db
        .collection('tshirt_orders')
        .where('status', isEqualTo: 'pending')
        .get();

    final newBookings = await _db
        .collection('saree_bookings')
        .where('status', isEqualTo: 'new')
        .get();

    return {
      'todayOrders': orders.docs.length,
      'todayBookings': bookings.docs.length,
      'pendingOrders': pendingOrders.docs.length,
      'newBookings': newBookings.docs.length,
    };
  }
}
