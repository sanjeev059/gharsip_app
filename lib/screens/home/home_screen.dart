import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/design_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/design_provider.dart';
import '../../providers/cart_provider.dart';
import '../tshirt/tshirt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final designs = context.watch<DesignProvider>();
    final name = auth.user?.name ?? '';
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBar(greeting: greeting, name: name),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _BannerCarousel()),
          SliverToBoxAdapter(child: _ServiceCards()),
          if (_searchQuery.isNotEmpty)
            _SearchResults(query: _searchQuery, designs: designs.filtered)
          else ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Popular Designs',
                onSeeAll: () => context.read<DesignProvider>().setCategory(null),
              ),
            ),
            _DesignGrid(designs: designs.popular),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'All Categories',
                onSeeAll: null,
              ),
            ),
            SliverToBoxAdapter(child: _CategoryChips()),
            _DesignGrid(designs: designs.filtered),
            SliverToBoxAdapter(child: _ReviewsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _AppBar extends StatelessWidget {
  final String greeting;
  final String name;
  const _AppBar({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      floating: true,
      snap: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
              Text(
                name.isNotEmpty ? 'Hey, $name!' : 'Hey there!',
                style: const TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            if (cartCount > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search designs...',
        hintStyle: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins'),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () { controller.clear(); onChanged(''); },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  int _current = 0;

  final _banners = const [
    _BannerData(
      title: 'Custom T-Shirts',
      subtitle: 'Delivered across India in 4-5 days',
      emoji: '👕',
      color: AppColors.primary,
    ),
    _BannerData(
      title: 'Saree Services',
      subtitle: 'Free home pickup in Bengaluru',
      emoji: '✂️',
      color: Color(0xFF1565C0),
    ),
    _BannerData(
      title: 'Bulk Orders',
      subtitle: 'Up to 40% off on 20+ pieces',
      emoji: '📦',
      color: Color(0xFF6A1B9A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PageView.builder(
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) {
                final b = _banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: b.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.title,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                            const SizedBox(height: 6),
                            Text(b.subtitle,
                              style: TextStyle(color: Colors.white.withOpacity(0.85),
                                  fontSize: 13, fontFamily: 'Poppins')),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: b.color,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: const Text('Shop Now',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                            ),
                          ],
                        ),
                      ),
                      Text(b.emoji, style: const TextStyle(fontSize: 64)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == i ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String title, subtitle, emoji;
  final Color color;
  const _BannerData({required this.title, required this.subtitle, required this.emoji, required this.color});
}

class _ServiceCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _ServiceCard(
            icon: Icons.checkroom,
            label: 'T-Shirts',
            color: AppColors.primary,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _ServiceCard(
            icon: Icons.content_cut,
            label: 'Saree',
            color: const Color(0xFF1565C0),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          const SizedBox(width: 12),
          _ServiceCard(
            icon: Icons.local_offer,
            label: 'Offers',
            color: const Color(0xFF6A1B9A),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ServiceCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700,
                    fontSize: 12, fontFamily: 'Poppins')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All',
                style: TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Poppins')),
            ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final _cats = const ['All', 'Fitness', 'Tech', 'Funny', 'Minimal', 'Kannada', 'Cricket'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DesignProvider>();
    final selected = provider.selectedCategory;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final isSelected = (cat == 'All' && selected == null) || cat == selected;
          return GestureDetector(
            onTap: () => provider.setCategory(cat == 'All' ? null : cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecond,
                  fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                )),
            ),
          );
        },
      ),
    );
  }
}

class _DesignGrid extends StatelessWidget {
  final List<DesignModel> designs;
  const _DesignGrid({required this.designs});

  @override
  Widget build(BuildContext context) {
    if (designs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No designs found', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _DesignCard(design: designs[i]),
          childCount: designs.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
      ),
    );
  }
}

class _DesignCard extends StatelessWidget {
  final DesignModel design;
  const _DesignCard({required this.design});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TshirtScreen(preselectedDesign: design)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: design.imageUrl.startsWith('http')
                      ? Image.network(design.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted))
                      : Text(design.emoji ?? '👕', style: const TextStyle(fontSize: 52)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(design.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Poppins'),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(design.category,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('from ₹399',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.primary, fontFamily: 'Poppins')),
                      Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<DesignModel> designs;
  const _SearchResults({required this.query, required this.designs});

  @override
  Widget build(BuildContext context) {
    final results = designs
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()) ||
            d.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results.isEmpty
        ? SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('No results for "$query"',
                      style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
          )
        : _DesignGrid(designs: results);
  }
}

class _ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Reviews',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          ..._reviews.map((r) => _ReviewCard(review: r)),
        ],
      ),
    );
  }

  static const _reviews = [
    ('Ravi K.', 'Koramangala', 'Love the print quality! T-shirt came out exactly as designed. Will order again.', 5),
    ('Meera S.', 'JP Nagar', 'Saree blouse stitching was perfect. They picked up and delivered same day!', 5),
    ('Arjun T.', 'Whitefield', 'Ordered 30 tees for our company event. Got 35% discount and delivered on time.', 4),
  ];
}

class _ReviewCard extends StatelessWidget {
  final (String, String, String, int) review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final (name, location, text, stars) = review;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryMuted,
                child: Text(name[0],
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Poppins')),
                  Text(location,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < stars ? Icons.star : Icons.star_outline,
                  size: 14, color: Colors.amber,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond,
                fontFamily: 'Poppins', height: 1.4)),
        ],
      ),
    );
  }
}
