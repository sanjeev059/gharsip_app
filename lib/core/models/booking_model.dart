class SareeBooking {
  final String bookingId;
  final String userId;
  final String name;
  final String phone;
  final List<String> services;
  final DateTime pickupDate;
  final String timeSlot;
  final String address;
  final String pincode;
  final String notes;
  final String status;
  final DateTime createdAt;

  const SareeBooking({
    required this.bookingId,
    required this.userId,
    required this.name,
    required this.phone,
    required this.services,
    required this.pickupDate,
    required this.timeSlot,
    required this.address,
    this.pincode = '',
    this.notes = '',
    this.status = 'new',
    required this.createdAt,
  });

  factory SareeBooking.fromMap(Map<String, dynamic> m, String id) => SareeBooking(
        bookingId: id,
        userId: m['user_id'] ?? '',
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        services: List<String>.from(m['services'] ?? []),
        pickupDate: (m['pickup_date'] is String)
            ? DateTime.tryParse(m['pickup_date']) ?? DateTime.now()
            : DateTime.now(),
        timeSlot: m['time_slot'] ?? '',
        address: m['address'] ?? '',
        pincode: m['pincode'] ?? '',
        notes: m['notes'] ?? '',
        status: m['status'] ?? 'new',
        createdAt: (m['created_at'] is String)
            ? DateTime.tryParse(m['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'phone': phone,
        'services': services,
        'pickup_date': pickupDate.toIso8601String(),
        'time_slot': timeSlot,
        'address': address,
        'pincode': pincode,
        'notes': notes,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  String get statusLabel {
    const labels = {
      'new': 'New',
      'confirmed': 'Confirmed',
      'picked_up': 'Picked Up',
      'in_progress': 'Processing',
      'ready': 'Ready',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
    };
    return labels[status] ?? status;
  }
}

// Saree service catalog
const kSareeServices = <String, Map<String, dynamic>>{
  'pico': {
    'emoji': '🪡',
    'name': 'Pico Work',
    'tagline': 'Neat edge finishing for all sarees',
    'description': 'Professional pico stitching for clean, durable saree edges. Available in simple, designer, and double pico styles.',
    'prices': <String, int>{'Simple Pico': 1000, 'Designer Pico': 1500, 'Double Pico': 2000},
  },
  'fall': {
    'emoji': '🧵',
    'name': 'Fall Stitching',
    'tagline': 'Strong fall attachment for longevity',
    'description': 'Expert fall stitching that keeps your saree in perfect shape. Plain, colour-matched, and designer fall options.',
    'prices': <String, int>{'Plain Fall': 1000, 'Colour Match': 1500, 'Designer Fall': 2000},
  },
  'blouse': {
    'emoji': '✂️',
    'name': 'Blouse Stitching',
    'tagline': 'Custom-fit blouses by expert tailors',
    'description': 'Beautifully tailored blouses to complement your saree. From plain to full bridal designs.',
    'prices': <String, int>{'Plain Blouse': 1000, 'Designer Blouse': 1500, 'Bridal Blouse': 2500},
  },
  'designs': {
    'emoji': '🎨',
    'name': 'Saree Design Work',
    'tagline': 'Borders, prints & embellishments',
    'description': 'Add beautiful borders, prints, stone work, embroidery, or zari detailing to your saree.',
    'prices': <String, int>{'Block Print Border': 1500, 'Stone/Sequin Border': 2500, 'Embroidery Border': 4000},
  },
};

// Saree packages
const kSareePackages = <Map<String, dynamic>>[
  {
    'name': 'Everyday Package',
    'price': '₹2,000',
    'tagline': 'Perfect for daily wear sarees',
    'includes': [
      '1 saree pico + fall stitching',
      '1 plain blouse stitching',
      'Free home pickup & delivery',
      'Ready in 4–5 days',
    ],
  },
  {
    'name': 'Festival Package',
    'price': '₹4,500',
    'tagline': 'Great value for special occasions',
    'includes': [
      '3 sarees pico + fall stitching',
      '1 designer blouse stitching',
      'Free home pickup & delivery',
      'Ready in 7–10 days',
    ],
  },
  {
    'name': 'Wedding Package',
    'price': '₹10,000+',
    'tagline': 'Complete bridal saree service',
    'includes': [
      'Bridal blouse full design',
      'Pico + fall for all sarees',
      'Embroidery on blouse',
      'Stone work on pallu',
      'Priority 12–15 day delivery',
    ],
  },
];
