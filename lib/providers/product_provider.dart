import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  ProductCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  ProductCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  ProductProvider() {
    _loadMockProducts();
  }

  void _loadMockProducts() {
    // Mock products for demo - in real app, this would come from a backend
    _products = [
      Product(
        id: '1',
        name: 'Fresh Tomatoes',
        description: 'Fresh organic tomatoes from local farms',
        price: 15.00,
        supplierId: 'supplier1',
        supplierName: 'Lusaka Fresh Farm',
        category: ProductCategory.agriculture,
        stockQuantity: 100,
        unit: 'kg',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        location: 'Lusaka',
        hasDelivery: true,
        deliveryFee: 5.00,
        estimatedDeliveryDays: 1,
      ),
      Product(
        id: '2',
        name: 'Rice (25kg)',
        description: 'High quality white rice, perfect for families',
        price: 180.00,
        supplierId: 'supplier2',
        supplierName: 'Zambian Grain Co.',
        category: ProductCategory.food,
        stockQuantity: 50,
        unit: 'bag',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Lusaka',
        hasDelivery: true,
        deliveryFee: 10.00,
        estimatedDeliveryDays: 2,
      ),
      Product(
        id: '3',
        name: 'Chitenge Fabric',
        description: 'Beautiful traditional Zambian chitenge patterns',
        price: 45.00,
        supplierId: 'supplier3',
        supplierName: 'African Textiles',
        category: ProductCategory.clothing,
        stockQuantity: 30,
        unit: 'piece',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        location: 'Lusaka',
        hasDelivery: true,
        deliveryFee: 8.00,
        estimatedDeliveryDays: 1,
      ),
      Product(
        id: '4',
        name: 'Solar Power Bank',
        description: 'Portable solar power bank for phones and devices',
        price: 120.00,
        supplierId: 'supplier4',
        supplierName: 'Tech Solutions ZM',
        category: ProductCategory.electronics,
        stockQuantity: 25,
        unit: 'piece',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        location: 'Lusaka',
        hasDelivery: true,
        deliveryFee: 12.00,
        estimatedDeliveryDays: 2,
      ),
      Product(
        id: '5',
        name: 'Cooking Oil (5L)',
        description: 'Pure sunflower cooking oil',
        price: 85.00,
        supplierId: 'supplier5',
        supplierName: 'Golden Oil Mills',
        category: ProductCategory.food,
        stockQuantity: 75,
        unit: 'bottle',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        location: 'Lusaka',
        hasDelivery: true,
        deliveryFee: 7.00,
        estimatedDeliveryDays: 1,
      ),
    ];
    
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Category filter
      if (_selectedCategory != null && product.category != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query) ||
               product.supplierName.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
    
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getProductsBySupplier(String supplierId) {
    return _products.where((product) => product.supplierId == supplierId).toList();
  }

  List<ProductCategory> get availableCategories {
    return _products.map((product) => product.category).toSet().toList();
  }

  Future<void> refreshProducts() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // In real app, fetch from backend
    _loadMockProducts();
    
    _isLoading = false;
    notifyListeners();
  }
}