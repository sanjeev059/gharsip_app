class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> images;
  final int mrp;
  final int price;
  final List<String> sizes;
  final List<Map<String, dynamic>> colors;
  final int stock;
  final List<String> tags;
  final bool active;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.images,
    required this.mrp,
    required this.price,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.tags,
    required this.active,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        description: m['description'] ?? '',
        category: m['category'] ?? '',
        images: List<String>.from(m['images'] ?? []),
        mrp: (m['mrp'] as num?)?.toInt() ?? 0,
        price: (m['price'] as num?)?.toInt() ?? 0,
        sizes: List<String>.from(m['sizes'] ?? []),
        colors: List<Map<String, dynamic>>.from(
          (m['colors'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
        ),
        stock: (m['stock'] as num?)?.toInt() ?? 0,
        tags: List<String>.from(m['tags'] ?? []),
        active: m['active'] ?? true,
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'category': category,
        'images': images,
        'mrp': mrp,
        'price': price,
        'sizes': sizes,
        'colors': colors,
        'stock': stock,
        'tags': tags,
        'active': active,
      };

  String get firstImage => images.isNotEmpty ? images.first : '';

  int get discount => mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;

  String get categoryLabel {
    const labels = {
      'tshirts': 'T-Shirts',
      'hoodies': 'Hoodies',
      'raincoats': 'Rain Coats',
      'sarees': 'Sarees',
      'accessories': 'Accessories',
      'others': 'Others',
    };
    return labels[category] ?? category;
  }
}

const kProductCategories = ['tshirts', 'hoodies', 'raincoats', 'sarees', 'accessories', 'others'];
const kProductSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Free Size'];
