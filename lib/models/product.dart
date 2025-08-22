enum ProductCategory {
  agriculture,
  food,
  clothing,
  electronics,
  home,
  health,
  automotive,
  services,
  other
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String supplierId;
  final String supplierName;
  final ProductCategory category;
  final String? imageUrl;
  final int stockQuantity;
  final String unit; // e.g., "kg", "pieces", "liters"
  final bool isAvailable;
  final DateTime createdAt;
  final String location; // Supplier's location
  final bool hasDelivery;
  final double? deliveryFee;
  final int? estimatedDeliveryDays;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.supplierId,
    required this.supplierName,
    required this.category,
    this.imageUrl,
    required this.stockQuantity,
    required this.unit,
    this.isAvailable = true,
    required this.createdAt,
    required this.location,
    this.hasDelivery = true,
    this.deliveryFee,
    this.estimatedDeliveryDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'category': category.toString(),
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'hasDelivery': hasDelivery,
      'deliveryFee': deliveryFee,
      'estimatedDeliveryDays': estimatedDeliveryDays,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ProductCategory.other,
      ),
      imageUrl: json['imageUrl'],
      stockQuantity: json['stockQuantity'],
      unit: json['unit'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      location: json['location'],
      hasDelivery: json['hasDelivery'] ?? true,
      deliveryFee: json['deliveryFee']?.toDouble(),
      estimatedDeliveryDays: json['estimatedDeliveryDays'],
    );
  }

  String get categoryName {
    switch (category) {
      case ProductCategory.agriculture:
        return 'Agriculture';
      case ProductCategory.food:
        return 'Food & Beverages';
      case ProductCategory.clothing:
        return 'Clothing';
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.home:
        return 'Home & Garden';
      case ProductCategory.health:
        return 'Health & Beauty';
      case ProductCategory.automotive:
        return 'Automotive';
      case ProductCategory.services:
        return 'Services';
      case ProductCategory.other:
        return 'Other';
    }
  }

  String get formattedPrice {
    return 'K${price.toStringAsFixed(2)}';
  }
}