import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import 'tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('My Orders',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'T-Shirts'),
            Tab(text: 'Saree Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _TshirtOrdersTab(),
          _SareeBookingsTab(),
        ],
      ),
    );
  }
}

class _TshirtOrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return const _NotLoggedIn();

    return StreamBuilder<List<TshirtOrder>>(
      stream: FirestoreService().userOrders(uid),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return _EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'No T-shirt orders yet',
            subtitle: 'Customise your first tee and order it!',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _TshirtOrderCard(order: orders[i]),
        );
      },
    );
  }
}

class _SareeBookingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return const _NotLoggedIn();

    return StreamBuilder<List<SareeBooking>>(
      stream: FirestoreService().userBookings(uid),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final bookings = snap.data ?? [];
        if (bookings.isEmpty) {
          return _EmptyState(
            icon: Icons.content_cut_outlined,
            title: 'No saree bookings yet',
            subtitle: 'Book a home pickup for your saree services!',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _SareeBookingCard(booking: bookings[i]),
        );
      },
    );
  }
}

class _TshirtOrderCard extends StatelessWidget {
  final TshirtOrder order;
  const _TshirtOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Text('👕', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.orderId,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.textMuted, fontFamily: 'Poppins')),
                          _StatusBadge(status: order.status, label: order.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, fontFamily: 'Poppins')),
                      Text('₹${order.total}',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                      const SizedBox(height: 2),
                      Text(DateFormat('d MMM yyyy').format(order.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (order.isActive)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TrackingScreen(order: order)),
                ),
                child: const Text('Track Order',
                  style: TextStyle(color: AppColors.primary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SareeBookingCard extends StatelessWidget {
  final SareeBooking booking;
  const _SareeBookingCard({required this.booking});

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(booking.bookingId,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.textMuted, fontFamily: 'Poppins')),
              _StatusBadge(status: booking.status, label: booking.statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: booking.services.map((s) {
              final svc = kSareeServices[s];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${svc?['emoji'] ?? '✂️'} ${svc?['name'] ?? s}',
                  style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontFamily: 'Poppins')),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(DateFormat('d MMM yyyy').format(booking.pickupDate),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins')),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(booking.timeSlot,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status, label;
  const _StatusBadge({required this.status, required this.label});

  static const _colors = {
    'pending': Color(0xFFFFF3CD),
    'confirmed': Color(0xFFD1ECF1),
    'printing': Color(0xFFCCE5FF),
    'qc': Color(0xFFD4EDDA),
    'shipped': Color(0xFFD1ECF1),
    'out_for_delivery': Color(0xFFCCE5FF),
    'delivered': Color(0xFFD4EDDA),
    'cancelled': Color(0xFFF8D7DA),
    'picked_up': Color(0xFFCCE5FF),
    'in_progress': Color(0xFFCCE5FF),
    'ready': Color(0xFFD4EDDA),
    'new': Color(0xFFFFF3CD),
  };

  static const _textColors = {
    'pending': Color(0xFF856404),
    'confirmed': Color(0xFF0C5460),
    'printing': Color(0xFF004085),
    'qc': Color(0xFF155724),
    'shipped': Color(0xFF0C5460),
    'out_for_delivery': Color(0xFF004085),
    'delivered': Color(0xFF155724),
    'cancelled': Color(0xFF721C24),
    'picked_up': Color(0xFF004085),
    'in_progress': Color(0xFF004085),
    'ready': Color(0xFF155724),
    'new': Color(0xFF856404),
  };

  @override
  Widget build(BuildContext context) {
    final bg = _colors[status] ?? const Color(0xFFF8F9FA);
    final fg = _textColors[status] ?? AppColors.textSecond;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: fg, fontFamily: 'Poppins')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Please log in to view orders',
        style: TextStyle(color: AppColors.textSecond, fontFamily: 'Poppins')),
    );
  }
}
