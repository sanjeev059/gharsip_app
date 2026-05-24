import 'cart_item.dart';

class TshirtOrder {
  final String orderId;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final List<CartItem> items;
  final int subtotal;
  final int delivery;
  final int total;
  final String status;
  final DateTime createdAt;

  const TshirtOrder({
    required this.orderId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.delivery,
    required this.total,
    this.status = 'pending',
    required this.createdAt,
  });

  // Parses backend MongoDB order format
  factory TshirtOrder.fromBackend(Map<String, dynamic> m) {
    final customer = (m['customer'] as Map<String, dynamic>?) ?? {};
    final rawLines = (m['lines'] as List<dynamic>?) ?? (m['items'] as List<dynamic>?) ?? [];
    final address = [
      customer['address1'] ?? '',
      customer['address2'] ?? '',
      customer['city'] ?? '',
      customer['state'] ?? '',
      customer['pincode'] ?? '',
    ].where((s) => s.toString().isNotEmpty).join(', ');

    return TshirtOrder(
      orderId: m['id'] ?? '',
      userId: m['userId'] ?? m['user_id'] ?? '',
      name: customer['name'] ?? m['name'] ?? '',
      phone: customer['phone'] ?? m['phone'] ?? '',
      address: address,
      items: rawLines.map((l) {
        final line = Map<String, dynamic>.from(l as Map);
        return CartItem(
          designId: line['designId'] ?? line['design_id'] ?? '',
          designName: line['designName'] ?? line['design_name'] ?? '',
          productType: line['productType'] ?? line['product_type'] ?? 'round',
          color: line['colorLabel'] ?? line['color'] ?? 'White',
          size: line['size'] ?? 'M',
          imageUrl: line['designUrl'] ?? line['image_url'] ?? '',
          quantity: (line['qty'] ?? line['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
      subtotal: (m['subtotal'] as num?)?.toInt() ?? 0,
      delivery: (m['delivery'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      status: m['status'] ?? 'pending',
      createdAt: DateTime.tryParse(m['createdAt'] ?? m['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Legacy Firestore format
  factory TshirtOrder.fromMap(Map<String, dynamic> m, String id) {
    final rawItems = (m['items'] as List<dynamic>?) ?? [];
    return TshirtOrder(
      orderId: id,
      userId: m['user_id'] ?? '',
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      address: m['address'] ?? '',
      items: rawItems.map((i) {
        final map = Map<String, dynamic>.from(i as Map);
        return CartItem(
          designId: map['design_id'] ?? '',
          designName: map['design_name'] ?? '',
          productType: map['product_type'] ?? 'Regular',
          color: map['color'] ?? 'White',
          size: map['size'] ?? 'M',
          imageUrl: map['image_url'] ?? '',
          quantity: (map['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList(),
      subtotal: (m['subtotal'] as num?)?.toInt() ?? 0,
      delivery: (m['delivery'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      status: m['status'] ?? 'pending',
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel {
    const labels = {
      'pending': 'Order Placed',
      'printing': 'Printing',
      'qc': 'Quality Check',
      'shipped': 'Shipped',
      'out_for_delivery': 'Out for Delivery',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
    };
    return labels[status] ?? status;
  }

  bool get isActive => !['delivered', 'cancelled'].contains(status);
}
