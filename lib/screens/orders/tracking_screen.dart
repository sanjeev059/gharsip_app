import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/order_model.dart';
import '../../core/models/cart_item.dart';

class TrackingScreen extends StatelessWidget {
  final TshirtOrder order;
  const TrackingScreen({super.key, required this.order});

  static const _steps = [
    ('pending', 'Order Placed', Icons.receipt_long_outlined),
    ('printing', 'Printing', Icons.print_outlined),
    ('qc', 'Quality Check', Icons.verified_outlined),
    ('shipped', 'Shipped', Icons.local_shipping_outlined),
    ('out_for_delivery', 'Out for Delivery', Icons.delivery_dining_outlined),
    ('delivered', 'Delivered', Icons.home_outlined),
  ];

  int get _currentStepIndex {
    final idx = _steps.indexWhere((s) => s.$1 == order.status);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(order.orderId,
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(order: order),
            const SizedBox(height: 16),
            _TrackingTimeline(steps: _steps, currentIndex: _currentStepIndex),
            const SizedBox(height: 16),
            _OrderItemsCard(order: order),
            const SizedBox(height: 16),
            _DeliveryInfoCard(order: order),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final TshirtOrder order;
  const _StatusCard({required this.order});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Status',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
              Text(DateFormat('d MMM yyyy').format(order.createdAt),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 8),
          Text(order.statusLabel,
            style: const TextStyle(color: Colors.white, fontSize: 22,
                fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text('Total: ₹${order.total}',
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final List<(String, String, IconData)> steps;
  final int currentIndex;
  const _TrackingTimeline({required this.steps, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking Timeline',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final (_, label, icon) = e.value;
            final isDone = i <= currentIndex;
            final isCurrent = i == currentIndex;
            return _TimelineStep(
              label: label,
              icon: icon,
              isDone: isDone,
              isCurrent: isCurrent,
              isLast: i == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone, isCurrent, isLast;
  const _TimelineStep({
    required this.label, required this.icon,
    required this.isDone, required this.isCurrent, required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.border,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Icon(
                isDone && !isCurrent ? Icons.check : icon,
                size: 18,
                color: isDone ? Colors.white : AppColors.textMuted,
              ),
            ),
            if (!isLast)
              Container(
                width: 2, height: 36,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                  fontFamily: 'Poppins',
                )),
              if (isCurrent)
                const Text('In progress',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontFamily: 'Poppins')),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  final TshirtOrder order;
  const _OrderItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('👕', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.designName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, fontFamily: 'Poppins')),
                      Text('${item.productType} · ${item.color} · ${item.size} · Qty: ${item.quantity}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
                Text('₹${item.total}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.primary, fontFamily: 'Poppins')),
              ],
            ),
          )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Poppins')),
              Text('₹${order.total}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.primary, fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryInfoCard extends StatelessWidget {
  final TshirtOrder order;
  const _DeliveryInfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          _InfoRow(Icons.person_outline, order.name),
          _InfoRow(Icons.phone_outlined, order.phone),
          _InfoRow(Icons.location_on_outlined, order.address),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins'))),
        ],
      ),
    );
  }
}
