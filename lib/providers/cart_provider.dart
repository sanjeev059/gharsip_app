import 'package:flutter/material.dart';
import '../core/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (s, i) => s + i.quantity);
  int get subtotal => _items.fold(0, (s, i) => s + i.total);
  int get delivery => subtotal >= 999 ? 0 : 60;
  int get total => subtotal + delivery;

  void addItem(CartItem item) {
    final idx = _items.indexWhere((i) =>
        i.designId == item.designId &&
        i.productType == item.productType &&
        i.color == item.color &&
        i.size == item.size);
    if (idx >= 0) {
      _items[idx].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQty(CartItem item, int qty) {
    if (qty <= 0) {
      removeItem(item);
      return;
    }
    item.quantity = qty;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
