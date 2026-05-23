import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressCtrl = TextEditingController();
  final _couponCtrl = TextEditingController();
  bool _placing = false;
  String? _couponError;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address'),
          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _placing = true);
    try {
      final cart = context.read<CartProvider>();
      final auth = context.read<AuthProvider>();
      final fs = FirestoreService();
      final orderId = await fs.createTshirtOrder(
        userId: auth.user!.uid,
        phone: auth.user!.phone,
        name: auth.user!.name,
        items: cart.items,
        subtotal: cart.subtotal,
        delivery: cart.delivery,
        total: cart.total,
        address: _addressCtrl.text.trim(),
      );
      cart.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/orders');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed! ID: $orderId',
              style: const TextStyle(fontFamily: 'Poppins')),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e'),
            backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Cart (${cart.count})',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, cart),
              child: const Text('Clear', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins')),
            ),
        ],
      ),
      body: cart.items.isEmpty ? _EmptyCart() : _CartContent(
        cart: cart,
        addressCtrl: _addressCtrl,
        couponCtrl: _couponCtrl,
        couponError: _couponError,
      ),
      bottomNavigationBar: cart.items.isEmpty ? null : _CheckoutBar(
        cart: cart,
        placing: _placing,
        onPlace: _placeOrder,
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('Remove all items from your cart?',
          style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins'))),
          ElevatedButton(
            onPressed: () { cart.clear(); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Clear', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('Add some awesome T-shirts to get started!',
            style: TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Shop Now', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final CartProvider cart;
  final TextEditingController addressCtrl, couponCtrl;
  final String? couponError;

  const _CartContent({
    required this.cart, required this.addressCtrl,
    required this.couponCtrl, this.couponError,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...cart.items.map((item) => _CartItemCard(item: item)),
        const SizedBox(height: 12),
        _AddressField(controller: addressCtrl),
        const SizedBox(height: 12),
        _PriceSummary(cart: cart),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('👕', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.designName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text('${item.productType} · ${item.color} · ${item.size}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('₹${item.unitPrice}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.primary, fontFamily: 'Poppins')),
                    const Spacer(),
                    _QtyControls(item: item, cart: cart),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
            onPressed: () => cart.removeItem(item),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _QtyControls extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;
  const _QtyControls({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QBtn(icon: Icons.remove, onTap: item.quantity > 1 ? () => cart.updateQty(item, item.quantity - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('${item.quantity}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        ),
        _QBtn(icon: Icons.add, onTap: () => cart.updateQty(item, item.quantity + 1)),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primaryMuted : AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: onTap != null ? AppColors.primary : AppColors.border),
        ),
        child: Icon(icon, size: 14, color: onTap != null ? AppColors.primary : AppColors.textMuted),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  const _AddressField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text('Delivery Address',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'House no., Street, Area, City, PIN',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontFamily: 'Poppins', fontSize: 13),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final CartProvider cart;
  const _PriceSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          _PRow('Subtotal (${cart.count} items)', '₹${cart.subtotal}'),
          _PRow('Delivery', cart.delivery == 0 ? 'FREE' : '₹${cart.delivery}',
            valueColor: cart.delivery == 0 ? AppColors.success : null),
          if (cart.delivery == 0)
            const Padding(
              padding: EdgeInsets.only(top: 2, bottom: 4),
              child: Text('Free delivery on orders above ₹999',
                style: TextStyle(fontSize: 11, color: AppColors.success, fontFamily: 'Poppins')),
            ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Poppins')),
              Text('₹${cart.total}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.primary, fontFamily: 'Poppins')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Delivered in 4-5 business days',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _PRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _PRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;
  final bool placing;
  final VoidCallback onPlace;

  const _CheckoutBar({required this.cart, required this.placing, required this.onPlace});

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
        child: ElevatedButton(
          onPressed: placing ? null : onPlace,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: placing
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text('Place Order  ·  ₹${cart.total}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
        ),
      ),
    );
  }
}
