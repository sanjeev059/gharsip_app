import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/design_model.dart';
import '../../core/models/cart_item.dart';
import '../../providers/design_provider.dart';
import '../../providers/cart_provider.dart';

class TshirtScreen extends StatefulWidget {
  final DesignModel? preselectedDesign;
  const TshirtScreen({super.key, this.preselectedDesign});

  @override
  State<TshirtScreen> createState() => _TshirtScreenState();
}

class _TshirtScreenState extends State<TshirtScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DesignModel? _selectedDesign;
  String _color = 'White';
  String _size = 'M';
  String _type = 'Regular';
  int _qty = 1;

  static const _colors = ['White', 'Black', 'Navy', 'Red', 'Royal Blue'];
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _types = ['Regular', 'Oversized', 'Polo'];

  static const _colorValues = {
    'White': Colors.white,
    'Black': Colors.black87,
    'Navy': Color(0xFF001F5B),
    'Red': Colors.red,
    'Royal Blue': Color(0xFF4169E1),
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _selectedDesign = widget.preselectedDesign;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignProvider>().init();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  int get _unitPrice {
    final base = AppStrings.tshirtPrices[_type] ?? 399;
    return _selectedDesign != null ? base : base - 150;
  }

  int get _total => _unitPrice * _qty;

  void _addToCart() {
    final item = CartItem(
      designId: _selectedDesign?.id ?? 'plain',
      designName: _selectedDesign?.name ?? 'Plain T-Shirt',
      productType: _type,
      color: _color,
      size: _size,
      quantity: _qty,
      imageUrl: _selectedDesign?.imageUrl ?? '',
    );
    context.read<CartProvider>().addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart!', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Custom T-Shirt',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Design'),
            Tab(text: 'Customise'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _DesignTab(
            selected: _selectedDesign,
            onSelect: (d) => setState(() { _selectedDesign = d; _tabCtrl.animateTo(1); }),
          ),
          _CustomiseTab(
            color: _color, size: _size, type: _type, qty: _qty,
            selectedDesign: _selectedDesign,
            colors: _colors, colorValues: _colorValues,
            sizes: _sizes, types: _types,
            onColorChange: (v) => setState(() => _color = v),
            onSizeChange: (v) => setState(() => _size = v),
            onTypeChange: (v) => setState(() => _type = v),
            onQtyChange: (v) => setState(() => _qty = v),
            onNext: () => _tabCtrl.animateTo(2),
          ),
          _SummaryTab(
            design: _selectedDesign,
            color: _color, size: _size, type: _type,
            qty: _qty, unitPrice: _unitPrice, total: _total,
            onAddToCart: _addToCart,
          ),
        ],
      ),
    );
  }
}

class _DesignTab extends StatelessWidget {
  final DesignModel? selected;
  final ValueChanged<DesignModel> onSelect;
  const _DesignTab({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final designs = context.watch<DesignProvider>();
    return Column(
      children: [
        _CategoryFilter(),
        Expanded(
          child: designs.filtered.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
                  itemCount: designs.filtered.length,
                  itemBuilder: (_, i) {
                    final d = designs.filtered[i];
                    final isSelected = selected?.id == d.id;
                    return GestureDetector(
                      onTap: () => onSelect(d),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryMuted,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                ),
                                child: Stack(
                                  children: [
                                    Center(child: Text(d.emoji ?? '👕', style: const TextStyle(fontSize: 52))),
                                    if (isSelected)
                                      Positioned(
                                        top: 8, right: 8,
                                        child: Container(
                                          width: 24, height: 24,
                                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(d.name,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text(d.category,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Poppins')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  static const _cats = ['All', 'Fitness', 'Tech', 'Funny', 'Minimal', 'Kannada', 'Cricket'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DesignProvider>();
    final selected = provider.selectedCategory;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _cats[i];
          final isSelected = (cat == 'All' && selected == null) || cat == selected;
          return GestureDetector(
            onTap: () => provider.setCategory(cat == 'All' ? null : cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(cat,
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

class _CustomiseTab extends StatelessWidget {
  final String color, size, type;
  final int qty;
  final DesignModel? selectedDesign;
  final List<String> colors, sizes, types;
  final Map<String, Color> colorValues;
  final ValueChanged<String> onColorChange, onSizeChange, onTypeChange;
  final ValueChanged<int> onQtyChange;
  final VoidCallback onNext;

  const _CustomiseTab({
    required this.color, required this.size, required this.type, required this.qty,
    required this.selectedDesign, required this.colors, required this.colorValues,
    required this.sizes, required this.types,
    required this.onColorChange, required this.onSizeChange, required this.onTypeChange,
    required this.onQtyChange, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorValues[color] ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedDesign?.emoji ?? '👕', style: const TextStyle(fontSize: 64)),
                  if (selectedDesign != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(selectedDesign!.name,
                        style: TextStyle(
                          color: color == 'White' || color == 'Red' ? Colors.black87 : Colors.white,
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                        )),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          _OptionSection(
            title: 'T-Shirt Type',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: types.map((t) => _SelectChip(
                label: t, isSelected: type == t, onTap: () => onTypeChange(t),
              )).toList(),
            ),
          ),

          _OptionSection(
            title: 'Color',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: colors.map((c) => GestureDetector(
                onTap: () => onColorChange(c),
                child: Tooltip(
                  message: c,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: colorValues[c],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == c ? AppColors.primary : AppColors.border,
                        width: color == c ? 3 : 1,
                      ),
                    ),
                    child: color == c
                        ? Icon(Icons.check,
                            color: c == 'White' ? AppColors.primary : Colors.white, size: 18)
                        : null,
                  ),
                ),
              )).toList(),
            ),
          ),

          _OptionSection(
            title: 'Size',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: sizes.map((s) => _SelectChip(
                label: s, isSelected: size == s, onTap: () => onSizeChange(s),
              )).toList(),
            ),
          ),

          _OptionSection(
            title: 'Quantity',
            child: Row(
              children: [
                _QtyButton(icon: Icons.remove, onTap: qty > 1 ? () => onQtyChange(qty - 1) : null),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('$qty',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
                _QtyButton(icon: Icons.add, onTap: () => onQtyChange(qty + 1)),
                const SizedBox(width: 12),
                if (qty >= 20)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Text('Bulk discount applies!',
                      style: TextStyle(color: Colors.amber.shade800, fontSize: 12, fontFamily: 'Poppins')),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Review Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _OptionSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _SelectChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecond,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13, fontFamily: 'Poppins',
          )),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.primaryMuted : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: onTap != null ? AppColors.primary : AppColors.border),
        ),
        child: Icon(icon,
          color: onTap != null ? AppColors.primary : AppColors.textMuted, size: 18),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final DesignModel? design;
  final String color, size, type;
  final int qty, unitPrice, total;
  final VoidCallback onAddToCart;

  const _SummaryTab({
    required this.design, required this.color, required this.size, required this.type,
    required this.qty, required this.unitPrice, required this.total, required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary, fontFamily: 'Poppins')),
                const SizedBox(height: 16),
                _Row(label: 'Design', value: design?.name ?? 'Plain (No Design)'),
                _Row(label: 'Type', value: type),
                _Row(label: 'Color', value: color),
                _Row(label: 'Size', value: size),
                _Row(label: 'Quantity', value: '$qty'),
                const Divider(height: 24),
                _Row(label: 'Unit Price', value: '₹$unitPrice'),
                if (qty >= 20)
                  _Row(label: 'Bulk Discount', value: '− ₹${(unitPrice * qty * 0.15).round()}',
                    valueColor: AppColors.success),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary, fontFamily: 'Poppins')),
                    Text('₹$total',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.primary, fontFamily: 'Poppins')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Free delivery on orders above ₹999. Delivered in 4-5 days.',
                    style: TextStyle(fontSize: 12, color: AppColors.primaryDark, fontFamily: 'Poppins')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text('Add to Cart  ·  ₹$total',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecond, fontFamily: 'Poppins')),
          Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
