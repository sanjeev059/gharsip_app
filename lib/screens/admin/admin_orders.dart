import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/order_model.dart';
import '../../core/services/api_service.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  List<TshirtOrder> _orders = [];
  bool _loading = true;
  String? _error;
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await ApiService.getAllOrders();
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<TshirtOrder> get _filtered => _statusFilter == 'all'
      ? _orders
      : _orders.where((o) => o.status == _statusFilter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('T-Shirt Orders',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: _statusFilter,
            statuses: _statuses,
            onSelect: (s) => setState(() => _statusFilter = s),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, style: const TextStyle(color: AppColors.error, fontFamily: 'Poppins')),
                          const SizedBox(height: 12),
                          ElevatedButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppColors.primary,
                        child: _filtered.isEmpty
                            ? const Center(child: Text('No orders',
                                style: TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins')))
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (_, i) => _AdminOrderCard(
                                  order: _filtered[i],
                                  onStatusChanged: _load,
                                ),
                              ),
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
  final VoidCallback onStatusChanged;
  const _AdminOrderCard({required this.order, required this.onStatusChanged});

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

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      await ApiService.updateOrderStatus(widget.order.orderId, status);
      widget.onStatusChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final nextStatus = _nextStatus[order.status];
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
                _ContactRow(name: order.name, phone: order.phone),
                const SizedBox(height: 4),
                Text('${order.items.length} item(s) · ₹${order.total}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, fontFamily: 'Poppins')),
                if (order.address.isNotEmpty)
                  Text(order.address,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                Text(DateFormat('d MMM yyyy, h:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
              ],
            ),
          ),
          if (order.status != 'delivered' && order.status != 'cancelled')
            Container(
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border))),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (nextLabel != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updating ? null : () => _updateStatus(nextStatus!),
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
                  if (nextLabel != null) const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _updating ? null : () => _updateStatus('cancelled'),
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

class _ContactRow extends StatelessWidget {
  final String name, phone;
  const _ContactRow({required this.name, required this.phone});

  void _call() => launchUrl(Uri.parse('tel:$phone'), mode: LaunchMode.externalApplication);
  void _whatsapp() => launchUrl(
    Uri.parse('https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}?text=Hi+$name%2C+regarding+your+Gharsip+order'),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(phone,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
        ),
        GestureDetector(
          onTap: _call,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted, borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.call, size: 15, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _whatsapp,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.chat, size: 15, color: Color(0xFF25D366)),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status, label;
  const _StatusBadge({required this.status, required this.label});

  static const _bg = {
    'pending': Color(0xFFFFF3CD), 'printing': Color(0xFFCCE5FF),
    'qc': Color(0xFFD4EDDA), 'shipped': Color(0xFFD1ECF1),
    'out_for_delivery': Color(0xFFCCE5FF), 'delivered': Color(0xFFD4EDDA),
    'cancelled': Color(0xFFF8D7DA),
  };
  static const _fg = {
    'pending': Color(0xFF856404), 'printing': Color(0xFF004085),
    'qc': Color(0xFF155724), 'shipped': Color(0xFF0C5460),
    'out_for_delivery': Color(0xFF004085), 'delivered': Color(0xFF155724),
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
