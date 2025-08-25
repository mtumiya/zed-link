enum PaymentMethod {
  mtn,
  airtel,
  zamtel,
  visa,
  mastercard,
  bankTransfer,
  cashOnDelivery
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded
}

class PaymentMethodInfo {
  final PaymentMethod method;
  final String name;
  final String description;
  final String icon;
  final bool isAvailable;

  const PaymentMethodInfo({
    required this.method,
    required this.name,
    required this.description,
    required this.icon,
    this.isAvailable = true,
  });

  static const List<PaymentMethodInfo> availableMethods = [
    PaymentMethodInfo(
      method: PaymentMethod.mtn,
      name: 'MTN Mobile Money',
      description: 'Pay with MTN MoMo',
      icon: '📱',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.airtel,
      name: 'Airtel Money',
      description: 'Pay with Airtel Money',
      icon: '📲',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.zamtel,
      name: 'Zamtel Kwacha',
      description: 'Pay with Zamtel Kwacha',
      icon: '💳',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.visa,
      name: 'Visa Card',
      description: 'Pay with Visa credit/debit card',
      icon: '💳',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.mastercard,
      name: 'Mastercard',
      description: 'Pay with Mastercard credit/debit card',
      icon: '💳',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.bankTransfer,
      name: 'Bank Transfer',
      description: 'Direct bank account transfer',
      icon: '🏦',
    ),
    PaymentMethodInfo(
      method: PaymentMethod.cashOnDelivery,
      name: 'Cash on Delivery',
      description: 'Pay when your order is delivered',
      icon: '💵',
    ),
  ];

  static PaymentMethodInfo getMethodInfo(PaymentMethod method) {
    return availableMethods.firstWhere((info) => info.method == method);
  }
}

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionReference;
  final String? phoneNumber; // For mobile money
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.transactionReference,
    this.phoneNumber,
    this.errorMessage,
    this.metadata,
  });

  String get statusName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String get formattedAmount => 'K${amount.toStringAsFixed(2)}';

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending || status == PaymentStatus.processing;
  bool get isFailed => status == PaymentStatus.failed || status == PaymentStatus.cancelled;

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? transactionReference,
    String? phoneNumber,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      transactionReference: transactionReference ?? this.transactionReference,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'method': method.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionReference': transactionReference,
      'phoneNumber': phoneNumber,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      amount: json['amount'].toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      transactionReference: json['transactionReference'],
      phoneNumber: json['phoneNumber'],
      errorMessage: json['errorMessage'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }
}