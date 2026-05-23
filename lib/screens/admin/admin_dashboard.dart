import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'admin_orders.dart';
import 'admin_bookings.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WelcomeCard(name: auth.user?.name ?? 'Admin'),
          const SizedBox(height: 16),
          _StatsSection(),
          const SizedBox(height: 20),
          const Text('Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          _QuickActions(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, ${name.isNotEmpty ? name : "Admin"}!',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                const Text('Gharsip Admin Panel',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
              ],
            ),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: FirestoreService().todayStats(),
      builder: (_, snap) {
        final stats = snap.data ?? {};
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              icon: Icons.receipt_long_outlined,
              label: 'Today Orders',
              value: '${stats['todayOrders'] ?? 0}',
              color: AppColors.primary,
            ),
            _StatCard(
              icon: Icons.content_cut_outlined,
              label: 'Today Bookings',
              value: '${stats['todayBookings'] ?? 0}',
              color: const Color(0xFF1565C0),
            ),
            _StatCard(
              icon: Icons.pending_outlined,
              label: 'Pending Orders',
              value: '${stats['pendingOrders'] ?? 0}',
              color: const Color(0xFFF57F17),
            ),
            _StatCard(
              icon: Icons.new_releases_outlined,
              label: 'New Bookings',
              value: '${stats['newBookings'] ?? 0}',
              color: const Color(0xFF6A1B9A),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                    color: color, fontFamily: 'Poppins')),
              Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted,
                    fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.checkroom_outlined,
          color: AppColors.primary,
          title: 'T-Shirt Orders',
          subtitle: 'View and manage all t-shirt orders',
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminOrders())),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.content_cut_outlined,
          color: const Color(0xFF1565C0),
          title: 'Saree Bookings',
          subtitle: 'View and manage saree service bookings',
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminBookings())),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.people_outline,
          color: const Color(0xFF6A1B9A),
          title: 'Customers',
          subtitle: 'View registered customers',
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.color, required this.title,
    required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Poppins')),
                  Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins')),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
