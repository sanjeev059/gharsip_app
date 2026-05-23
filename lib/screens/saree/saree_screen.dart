import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/booking_model.dart';
import 'booking_screen.dart';

class SareeScreen extends StatefulWidget {
  const SareeScreen({super.key});

  @override
  State<SareeScreen> createState() => _SareeScreenState();
}

class _SareeScreenState extends State<SareeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saree Services',
                          style: TextStyle(color: Colors.white, fontSize: 24,
                              fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                        const SizedBox(height: 4),
                        Text('Pico, Fall & Blouse Stitching · Bengaluru',
                          style: TextStyle(color: Colors.white.withOpacity(0.85),
                              fontSize: 13, fontFamily: 'Poppins')),
                        const SizedBox(height: 10),
                        _ServiceAreaChips(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Services'),
                Tab(text: 'Packages'),
                Tab(text: 'How It Works'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ServicesTab(),
            _PackagesTab(),
            _HowItWorksTab(),
            _ReviewsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _BookNowBar(),
    );
  }
}

class _ServiceAreaChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: AppStrings.serviceAreas.map((area) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(area,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins')),
      )).toList(),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TrustBar(),
        const SizedBox(height: 16),
        ...kSareeServices.entries.map((e) => _ServiceCard(serviceKey: e.key, service: e.value)),
      ],
    );
  }
}

class _TrustBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _Trust(icon: Icons.home_outlined, label: 'Free\nPickup'),
          _Trust(icon: Icons.timer_outlined, label: 'Same\nDay'),
          _Trust(icon: Icons.verified_outlined, label: 'Quality\nChecked'),
          _Trust(icon: Icons.support_agent_outlined, label: '24/7\nSupport'),
        ],
      ),
    );
  }
}

class _Trust extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Trust({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.primaryDark,
              fontFamily: 'Poppins', height: 1.3)),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String serviceKey;
  final Map<String, dynamic> service;
  const _ServiceCard({required this.serviceKey, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(service['emoji'] as String,
            style: const TextStyle(fontSize: 24))),
        ),
        title: Text(service['name'] as String,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
        subtitle: Text(service['tagline'] as String,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
        children: [
          Text(service['description'] as String,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond,
                fontFamily: 'Poppins', height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: (service['prices'] as Map<String, int>).entries.map((p) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${p.key}: ₹${p.value}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark, fontFamily: 'Poppins')),
              )
            ).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingScreen(preselectedService: serviceKey)),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Book This Service',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackagesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Value Packages',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 4),
        const Text('Bundle and save on all your saree needs',
          style: TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
        const SizedBox(height: 16),
        ...kSareePackages.asMap().entries.map((e) => _PackageCard(pkg: e.value, index: e.key)),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final Map<String, dynamic> pkg;
  final int index;
  const _PackageCard({required this.pkg, required this.index});

  static const _colors = [AppColors.primary, Color(0xFF1565C0), Color(0xFF6A1B9A)];
  static const _highlights = [false, true, false];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final isHighlighted = _highlights[index % _highlights.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlighted ? color : AppColors.border, width: isHighlighted ? 2 : 1),
        boxShadow: isHighlighted ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 16)] : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              children: [
                if (isHighlighted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Most Popular',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black87)),
                  ),
                Text(pkg['name'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text(pkg['price'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 24,
                      fontWeight: FontWeight.w900, fontFamily: 'Poppins')),
                Text(pkg['tagline'] as String,
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...(pkg['includes'] as List<String>).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins'))),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Book Package',
                      style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _Step(n: 1, icon: Icons.phone_outlined, title: 'Book Online',
          desc: 'Fill the booking form with your address and preferred services.'),
        _Step(n: 2, icon: Icons.local_shipping_outlined, title: 'Free Home Pickup',
          desc: 'We\'ll pick up your saree at your doorstep on the same day.'),
        _Step(n: 3, icon: Icons.content_cut_outlined, title: 'Expert Processing',
          desc: 'Skilled craftspeople handle pico, fall stitching, or blouse tailoring.'),
        _Step(n: 4, icon: Icons.verified_outlined, title: 'Quality Check',
          desc: 'Every piece is quality-checked before it leaves our studio.'),
        _Step(n: 5, icon: Icons.home_outlined, title: 'Delivered to You',
          desc: 'Your saree is delivered back to your home, perfectly finished.'),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final IconData icon;
  final String title, desc;
  const _Step({required this.n, required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text('$n',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Poppins'))),
              ),
              if (n < 5)
                Container(width: 2, height: 40, color: AppColors.primaryMuted),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, fontFamily: 'Poppins')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecond,
                        fontFamily: 'Poppins', height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ReviewCard(name: 'Sunita R.', area: 'Koramangala', stars: 5,
          text: 'Amazing pico work! They picked up in the morning and delivered by evening. Will use again.'),
        _ReviewCard(name: 'Divya M.', area: 'HSR Layout', stars: 5,
          text: 'Got 3 sarees done in the Festival Package. Perfect blouse stitching, highly recommend!'),
        _ReviewCard(name: 'Lakshmi P.', area: 'Jayanagar', stars: 4,
          text: 'Good service, very professional. The fall attachment was neat and clean.'),
        _ReviewCard(name: 'Kavitha B.', area: 'BTM Layout', stars: 5,
          text: 'Wedding package was worth every rupee. All 8 sarees came back beautifully done.'),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name, area, text;
  final int stars;
  const _ReviewCard({required this.name, required this.area, required this.text, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                radius: 18, backgroundColor: AppColors.primaryMuted,
                child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  Text(area, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                ],
              ),
              const Spacer(),
              Row(children: List.generate(5, (i) => Icon(
                i < stars ? Icons.star : Icons.star_outline, size: 14, color: Colors.amber))),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecond,
              fontFamily: 'Poppins', height: 1.4)),
        ],
      ),
    );
  }
}

class _BookNowBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookingScreen()),
          ),
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: const Text('Book Home Pickup',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
