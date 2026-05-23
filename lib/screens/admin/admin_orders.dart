import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/services/firestore_service.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  String _statusFilter = 'all';

  static const _statuses = [
    ('all', 'All'),
    ('pending', 'Pending'),
    ('printing', 'Printing'),
    ('qc', 'QC'),
    ('shipped', 'Shipped'),
    ('out_for_delivery', 'OFD'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('T-Shirt Orders',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _FilterBar(selected: _statusFilter, statuses: _statuses,
            onSelect: (s) => setState(() => _statusFilter = s)),
          Expanded(
            child: StreamBuilder<List<TshirtOrder>>(
              stream: FirestoreService().allOrders(),
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final all = snap.data ?? [];
                final filtered = _statusFilter == 'all'
                    ? all
                    : all.where((o) => o.status == _statusFilter).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No orders', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _AdminOrderCard(order: filtered[i]),
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
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
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

class _AdminOrderCard extends StatefulWidget {
  final TshirtOrder order;
  const _AdminOrderCard({required this.order});

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  bool _updating = false;

  static const _nextStatus = {
    'pending': 'printing',
    'printing': 'qc',
    'qc': 'shipped',
    'shipped': 'out_for_delivery',
    'out_for_delivery': 'delivered',
  };

  static const _nextLabel = {
    'pending': 'Mark Printing',
    'printing': 'Mark QC',
    'qc': 'Mark Shipped',
    'shipped': 'Mark OFD',
    'out_for_delivery': 'Mark Delivered',
  };

  Future<void> _advance() async {
    final next = _nextStatus[widget.order.status];
    if (next == null) return;
    setState(() => _updating = true);
    try {
      await FirestoreService().updateOrderStatus(widget.order.orderId, next);
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
      await FirestoreService().updateOrderStatus(widget.order.orderId, 'cancelled');
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final nextLabel = _nextLabel[order.status];
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
                    Text(order.orderId,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontFamily: 'Poppins')),
                    _StatusBadge(status: order.status, label: order.statusLabel),
                  ],
                ),
                const SizedBox(height: 6),
                Text(order.name,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
                Text(order.phone,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
                const SizedBox(height: 4),
                Text('${order.items.length} item(s) · ₹${order.total}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary, fontFamily: 'Poppins')),
                Text(DateFormat('d MMM yyyy, h:mm a').format(order.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
              ],
            ),
          ),
          if (nextLabel != null || order.status != 'cancelled')
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
                          backgroundColor: AppColors.primary,
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
                  if (nextLabel != null && order.status != 'cancelled') const SizedBox(width: 8),
                  if (order.status != 'delivered' && order.status != 'cancelled')
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
    'pending': Color(0xFFFFF3CD),
    'printing': Color(0xFFCCE5FF),
    'qc': Color(0xFFD4EDDA),
    'shipped': Color(0xFFD1ECF1),
    'out_for_delivery': Color(0xFFCCE5FF),
    'delivered': Color(0xFFD4EDDA),
    'cancelled': Color(0xFFF8D7DA),
  };

  static const _fg = {
    'pending': Color(0xFF856404),
    'printing': Color(0xFF004085),
    'qc': Color(0xFF155724),
    'shipped': Color(0xFF0C5460),
    'out_for_delivery': Color(0xFF004085),
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
