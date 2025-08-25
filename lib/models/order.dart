import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded
}

enum DeliveryMethod {
  supplierDelivery,
  courierDelivery,
  pickup
}

class Order {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final DeliveryMethod deliveryMethod;
  final String deliveryAddress;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? notes;
  final String? trackingId;

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.status = OrderStatus.pending,
    required this.deliveryMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedDelivery,
    this.notes,
    this.trackingId,
  });

  String get statusName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  String get deliveryMethodName {
    switch (deliveryMethod) {
      case DeliveryMethod.supplierDelivery:
        return 'Supplier Delivery';
      case DeliveryMethod.courierDelivery:
        return 'Courier Delivery';
      case DeliveryMethod.pickup:
        return 'Pickup';
    }
  }

  String get formattedTotal => 'K${total.toStringAsFixed(2)}';
  String get formattedSubtotal => 'K${subtotal.toStringAsFixed(2)}';
  String get formattedDeliveryFee => 'K${deliveryFee.toStringAsFixed(2)}';

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, String> get supplierGroups {
    Map<String, String> suppliers = {};
    for (var item in items) {
      suppliers[item.product.supplierId] = item.product.supplierName;
    }
    return suppliers;
  }

  List<CartItem> getItemsBySupplier(String supplierId) {
    return items.where((item) => item.product.supplierId == supplierId).toList();
  }

  Order copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    List<CartItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    DeliveryMethod? deliveryMethod,
    String? deliveryAddress,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? notes,
    String? trackingId,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      notes: notes ?? this.notes,
      trackingId: trackingId ?? this.trackingId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.toString(),
      'deliveryMethod': deliveryMethod.toString(),
      'deliveryAddress': deliveryAddress,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'notes': notes,
      'trackingId': trackingId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      subtotal: json['subtotal'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      total: json['total'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryMethod: DeliveryMethod.values.firstWhere(
        (e) => e.toString() == json['deliveryMethod'],
        orElse: () => DeliveryMethod.courierDelivery,
      ),
      deliveryAddress: json['deliveryAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      estimatedDelivery: json['estimatedDelivery'] != null 
          ? DateTime.parse(json['estimatedDelivery']) 
          : null,
      notes: json['notes'],
      trackingId: json['trackingId'],
    );
  }
}