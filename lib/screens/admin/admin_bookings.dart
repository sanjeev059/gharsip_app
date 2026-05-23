import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/booking_model.dart';
import '../../core/services/firestore_service.dart';

class AdminBookings extends StatefulWidget {
  const AdminBookings({super.key});

  @override
  State<AdminBookings> createState() => _AdminBookingsState();
}

class _AdminBookingsState extends State<AdminBookings> {
  String _statusFilter = 'all';

  static const _statuses = [
    ('all', 'All'),
    ('new', 'New'),
    ('confirmed', 'Confirmed'),
    ('picked_up', 'Picked Up'),
    ('in_progress', 'Processing'),
    ('ready', 'Ready'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Saree Bookings',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _FilterBar(selected: _statusFilter, statuses: _statuses,
            onSelect: (s) => setState(() => _statusFilter = s)),
          Expanded(
            child: StreamBuilder<List<SareeBooking>>(
              stream: FirestoreService().allBookings(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final all = snap.data ?? [];
                final filtered = _statusFilter == 'all'
                    ? all
                    : all.where((b) => b.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No bookings', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AdminBookingCard(booking: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final List<(String, String)> statuses;
  final ValueChanged<String> onSelect;

  const _FilterBar({required this.selected, required this.statuses, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final (key, label) = statuses[i];
          final isSelected = key == selected;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1565C0) : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFF1565C0) : AppColors.border),
              ),
              child: Text(label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecond,
                  fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins',
                )),
            ),
          );
        },
      ),
    );
  }
}

class _AdminBookingCard extends StatefulWidget {
  final SareeBooking booking;
  const _AdminBookingCard({required this.booking});

  @override
  State<_AdminBookingCard> createState() => _AdminBookingCardState();
}

class _AdminBookingCardState extends State<_AdminBookingCard> {
  bool _updating = false;

  static const _nextStatus = {
    'new': 'confirmed',
    'confirmed': 'picked_up',
    'picked_up': 'in_progress',
    'in_progress': 'ready',
    'ready': 'delivered',
  };

  static const _nextLabel = {
    'new': 'Confirm',
    'confirmed': 'Mark Picked Up',
    'picked_up': 'Mark Processing',
    'in_progress': 'Mark Ready',
    'ready': 'Mark Delivered',
  };

  Future<void> _advance() async {
    final next = _nextStatus[widget.booking.status];
    if (next == null) return;
    setState(() => _updating = true);
    try {
      await FirestoreService().updateBookingStatus(widget.booking.bookingId, next);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      setState(() => _updating = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _updating = true);
    try {
      await FirestoreService().updateBookingStatus(widget.booking.bookingId, 'cancelled');
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final nextLabel = _nextLabel[b.status];
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(b.bookingId,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontFamily: 'Poppins')),
                    _StatusBadge(status: b.status, label: b.statusLabel),
                  ],
                ),
                const SizedBox(height: 6),
                Text(b.name,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
                Text(b.phone,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: b.services.map((s) {
                    final svc = kSareeServices[s];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${svc?['emoji'] ?? '✂️'} ${svc?['name'] ?? s}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0), fontFamily: 'Poppins')),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(DateFormat('d MMM yyyy').format(b.pickupDate),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins')),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(b.timeSlot,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(b.address,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecond, fontFamily: 'Poppins'))),
                  ],
                ),
              ],
            ),
          ),
          if (b.status != 'delivered' && b.status != 'cancelled')
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (nextLabel != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updating ? null : _advance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: _updating
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(nextLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                      ),
                    ),
                  if (nextLabel != null) const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _updating ? null : _cancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                    child: const Text('Cancel',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status, label;
  const _StatusBadge({required this.status, required this.label});

  static const _bg = {
    'new': Color(0xFFFFF3CD),
    'confirmed': Color(0xFFD1ECF1),
    'picked_up': Color(0xFFCCE5FF),
    'in_progress': Color(0xFFCCE5FF),
    'ready': Color(0xFFD4EDDA),
    'delivered': Color(0xFFD4EDDA),
    'cancelled': Color(0xFFF8D7DA),
  };

  static const _fg = {
    'new': Color(0xFF856404),
    'confirmed': Color(0xFF0C5460),
    'picked_up': Color(0xFF004085),
    'in_progress': Color(0xFF004085),
    'ready': Color(0xFF155724),
    'delivered': Color(0xFF155724),
    'cancelled': Color(0xFF721C24),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg[status] ?? const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: _fg[status] ?? AppColors.textSecond, fontFamily: 'Poppins')),
    );
  }
}
