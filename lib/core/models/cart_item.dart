class CartItem {
  final String designId;
  final String designName;
  final String productType;
  final String color;
  final String size;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.designId,
    required this.designName,
    required this.productType,
    required this.color,
    required this.size,
    required this.imageUrl,
    this.quantity = 1,
  });

  static const _basePrices = {
    'Regular': 399,
    'Oversized': 499,
    'Polo': 549,
  };

  int get unitPrice {
    final base = _basePrices[productType] ?? 399;
    return designId == 'plain' ? base - 150 : base;
  }

  int get total => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'design_id': designId,
        'design_name': designName,
        'product_type': productType,
        'color': color,
        'size': size,
        'image_url': imageUrl,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
      };
}
