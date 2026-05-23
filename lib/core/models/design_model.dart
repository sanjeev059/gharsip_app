class DesignModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String? emoji;
  final int price;
  final bool isActive;
  final int orderCount;
  final String? tag;

  const DesignModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    this.emoji,
    required this.price,
    this.isActive = true,
    this.orderCount = 0,
    this.tag,
  });

  factory DesignModel.fromMap(Map<String, dynamic> m, String id) => DesignModel(
        id: id,
        name: m['name'] ?? '',
        category: m['category'] ?? 'all',
        imageUrl: m['image_url'] ?? '',
        emoji: m['emoji'],
        price: (m['price'] as num?)?.toInt() ?? 150,
        isActive: m['is_active'] ?? true,
        orderCount: (m['order_count'] as num?)?.toInt() ?? 0,
        tag: m['tag'],
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'image_url': imageUrl,
        if (emoji != null) 'emoji': emoji,
        'price': price,
        'is_active': isActive,
        'order_count': orderCount,
        if (tag != null) 'tag': tag,
      };
}

final kSampleDesigns = [
  const DesignModel(id: 'fit-1', name: 'Beast Mode ON',         category: 'Fitness',  imageUrl: '', emoji: '💪', price: 150, tag: 'Popular'),
  const DesignModel(id: 'fit-2', name: 'No Pain No Gain',       category: 'Fitness',  imageUrl: '', emoji: '🏋️', price: 150),
  const DesignModel(id: 'fit-3', name: 'Train Hard Stay Humble', category: 'Fitness', imageUrl: '', emoji: '🔥', price: 160),
  const DesignModel(id: 'fit-4', name: 'Gym Life',              category: 'Fitness',  imageUrl: '', emoji: '🏃', price: 150),
  const DesignModel(id: 'fit-5', name: 'Sweat Now Shine Later', category: 'Fitness',  imageUrl: '', emoji: '⚡', price: 160),
  const DesignModel(id: 'fit-6', name: 'Lift Heavy Live Happy', category: 'Fitness',  imageUrl: '', emoji: '🏆', price: 150),
  const DesignModel(id: 'tf-1',  name: '404 Sleep Not Found',   category: 'Tech',     imageUrl: '', emoji: '💻', price: 175, tag: 'Popular'),
  const DesignModel(id: 'tf-2',  name: 'Bug Free Code',        category: 'Funny',    imageUrl: '', emoji: '🐛', price: 150),
  const DesignModel(id: 'tf-3',  name: 'I Run On Coffee',      category: 'Tech',     imageUrl: '', emoji: '☕', price: 150),
  const DesignModel(id: 'tf-4',  name: 'Born To Code',         category: 'Tech',     imageUrl: '', emoji: '⌨️', price: 165, tag: 'New'),
  const DesignModel(id: 'tf-5',  name: 'Ctrl Alt Delete',      category: 'Tech',     imageUrl: '', emoji: '🖥️', price: 155),
  const DesignModel(id: 'tf-6',  name: 'Loading Please Wait',  category: 'Funny',    imageUrl: '', emoji: '⏳', price: 160),
  const DesignModel(id: 'min-1', name: 'Mountain Minimal',     category: 'Minimal',  imageUrl: '', emoji: '🏔️', price: 175, tag: 'Popular'),
  const DesignModel(id: 'min-2', name: 'Simple Wave',          category: 'Minimal',  imageUrl: '', emoji: '🌊', price: 170),
  const DesignModel(id: 'min-3', name: 'Geometric Abstract',   category: 'Minimal',  imageUrl: '', emoji: '🔷', price: 180),
  const DesignModel(id: 'min-4', name: 'Simple Sun',           category: 'Minimal',  imageUrl: '', emoji: '☀️', price: 165),
  const DesignModel(id: 'kn-1',  name: 'Bengaluru ಬೆಂಗಳೂರು',   category: 'Kannada',  imageUrl: '', emoji: '🦁', price: 190, tag: 'Popular'),
  const DesignModel(id: 'kn-2',  name: 'Namma Karnataka',     category: 'Kannada',  imageUrl: '', emoji: '🌺', price: 185),
  const DesignModel(id: 'kn-3',  name: 'Kannada Pride',       category: 'Kannada',  imageUrl: '', emoji: '🏛️', price: 175),
  const DesignModel(id: 'kn-4',  name: 'Namma Bengaluru',     category: 'Kannada',  imageUrl: '', emoji: '🌆', price: 180),
  const DesignModel(id: 'cr-1',  name: 'Straight Drive',      category: 'Cricket',  imageUrl: '', emoji: '🏏', price: 160, tag: 'Trending'),
  const DesignModel(id: 'cr-2',  name: 'Game Day',            category: 'Cricket',  imageUrl: '', emoji: '🏆', price: 155),
];
