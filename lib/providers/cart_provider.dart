import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee {
    if (_items.isEmpty) return 0.0;
    
    // Group items by supplier and calculate delivery fees
    Map<String, double> supplierFees = {};
    for (var item in _items) {
      if (item.product.hasDelivery && item.product.deliveryFee != null) {
        final supplierId = item.product.supplierId;
        if (!supplierFees.containsKey(supplierId)) {
          supplierFees[supplierId] = item.product.deliveryFee!;
        }
      }
    }
    
    return supplierFees.values.fold(0.0, (sum, fee) => sum + fee);
  }
  
  double get total => subtotal + deliveryFee;
  
  String get formattedSubtotal => 'K${subtotal.toStringAsFixed(2)}';
  String get formattedDeliveryFee => 'K${deliveryFee.toStringAsFixed(2)}';
  String get formattedTotal => 'K${total.toStringAsFixed(2)}';

  Map<String, List<CartItem>> get itemsBySupplier {
    Map<String, List<CartItem>> grouped = {};
    for (var item in _items) {
      final supplierId = item.product.supplierId;
      if (!grouped.containsKey(supplierId)) {
        grouped[supplierId] = [];
      }
      grouped[supplierId]!.add(item);
    }
    return grouped;
  }

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart_items');
    
    if (cartJson != null) {
      try {
        final List<dynamic> decoded = json.decode(cartJson);
        _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading cart: $e');
        _items = [];
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('cart_items', cartJson);
  }

  void addItem(Product product, int quantity) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = _items[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      // Check stock availability
      if (newQuantity <= product.stockQuantity) {
        _items[existingItemIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        // Set to maximum available stock
        _items[existingItemIndex] = existingItem.copyWith(
          quantity: product.stockQuantity,
        );
      }
    } else {
      // Add new item
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity.clamp(1, product.stockQuantity),
        addedAt: DateTime.now(),
      );
      _items.add(cartItem);
    }
    
    _saveCart();
    notifyListeners();
  }

  void updateItemQuantity(String itemId, int quantity) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    
    if (itemIndex >= 0) {
      if (quantity <= 0) {
        removeItem(itemId);
      } else {
        final item = _items[itemIndex];
        final clampedQuantity = quantity.clamp(1, item.product.stockQuantity);
        _items[itemIndex] = item.copyWith(quantity: clampedQuantity);
        _saveCart();
        notifyListeners();
      }
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getProductQuantityInCart(String productId) {
    try {
      final item = _items.firstWhere((item) => item.product.id == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<Order> createOrder({
    required String clientId,
    required String clientName,
    required String clientPhone,
    required String deliveryAddress,
    required DeliveryMethod deliveryMethod,
    String? notes,
  }) async {
    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      clientId: clientId,
      clientName: clientName,
      clientPhone: clientPhone,
      items: List.from(_items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      deliveryMethod: deliveryMethod,
      deliveryAddress: deliveryAddress,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
      notes: notes,
      trackingId: 'TRK${DateTime.now().millisecondsSinceEpoch}',
    );

    // Clear cart after creating order
    clearCart();

    return order;
  }
}