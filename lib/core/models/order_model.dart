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

  factory TshirtOrder.fromMap(Map<String, dynamic> m, String id) {
    final rawItems = (m['items'] as List<dynamic>?) ?? [];
    final items = rawItems.map((i) {
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
    }).toList();

    return TshirtOrder(
      orderId: id,
      userId: m['user_id'] ?? '',
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      address: m['address'] ?? '',
      items: items,
      subtotal: (m['subtotal'] as num?)?.toInt() ?? 0,
      delivery: (m['delivery'] as num?)?.toInt() ?? 0,
      total: (m['total'] as num?)?.toInt() ?? 0,
      status: m['status'] ?? 'pending',
      createdAt: (m['created_at'] is String)
          ? DateTime.tryParse(m['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'phone': phone,
        'address': address,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'delivery': delivery,
        'total': total,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

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
