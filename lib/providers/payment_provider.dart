import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/order.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  Payment? _currentPayment;
  bool _isProcessing = false;
  Function(Payment)? _onPaymentCompleted;

  List<Payment> get payments => _payments;
  Payment? get currentPayment => _currentPayment;
  bool get isProcessing => _isProcessing;

  void setOnPaymentCompletedCallback(Function(Payment) callback) {
    _onPaymentCompleted = callback;
  }

  Future<Payment> initiatePayment({
    required Order order,
    required PaymentMethod method,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final payment = Payment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        orderId: order.id,
        amount: order.total,
        method: method,
        createdAt: DateTime.now(),
        phoneNumber: phoneNumber,
        metadata: metadata,
      );

      _currentPayment = payment;
      _payments.add(payment);
      
      // Simulate payment processing based on method
      await _processPayment(payment);
      
      return payment;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _processPayment(Payment payment) async {
    switch (payment.method) {
      case PaymentMethod.mtn:
      case PaymentMethod.airtel:
      case PaymentMethod.zamtel:
        await _processMobileMoneyPayment(payment);
        break;
      case PaymentMethod.visa:
      case PaymentMethod.mastercard:
        await _processCardPayment(payment);
        break;
      case PaymentMethod.bankTransfer:
        await _processBankTransfer(payment);
        break;
      case PaymentMethod.cashOnDelivery:
        await _processCashOnDelivery(payment);
        break;
    }
  }

  Future<void> _processMobileMoneyPayment(Payment payment) async {
    // Simulate mobile money processing
    _updatePaymentStatus(payment.id, PaymentStatus.processing);
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Simulate success/failure (90% success rate for demo)
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    
    if (random < 9) {
      // Success
      final transactionRef = 'MM${DateTime.now().millisecondsSinceEpoch}';
      _updatePayment(payment.id, 
        status: PaymentStatus.completed,
        transactionReference: transactionRef,
        completedAt: DateTime.now(),
      );
      
      // Trigger notification callback
      final completedPayment = _payments.firstWhere((p) => p.id == payment.id);
      _onPaymentCompleted?.call(completedPayment);
    } else {
      // Failure
      _updatePayment(payment.id,
        status: PaymentStatus.failed,
        errorMessage: 'Insufficient balance or network error',
      );
    }
  }

  Future<void> _processCardPayment(Payment payment) async {
    // Simulate card processing
    _updatePaymentStatus(payment.id, PaymentStatus.processing);
    
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 4));
    
    // Simulate success/failure (85% success rate for demo)
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    
    if (random < 8) {
      // Success
      final transactionRef = 'CARD${DateTime.now().millisecondsSinceEpoch}';
      _updatePayment(payment.id,
        status: PaymentStatus.completed,
        transactionReference: transactionRef,
        completedAt: DateTime.now(),
      );
      
      // Trigger notification callback
      final completedPayment = _payments.firstWhere((p) => p.id == payment.id);
      _onPaymentCompleted?.call(completedPayment);
    } else {
      // Failure
      _updatePayment(payment.id,
        status: PaymentStatus.failed,
        errorMessage: 'Card declined or expired',
      );
    }
  }

  Future<void> _processBankTransfer(Payment payment) async {
    // Bank transfer requires manual confirmation
    _updatePaymentStatus(payment.id, PaymentStatus.processing);
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Bank transfers are usually successful but take longer to confirm
    final transactionRef = 'BT${DateTime.now().millisecondsSinceEpoch}';
    _updatePayment(payment.id,
      status: PaymentStatus.processing, // Would be confirmed later in real system
      transactionReference: transactionRef,
      metadata: {
        'requiresConfirmation': true,
        'estimatedConfirmation': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      },
    );
  }

  Future<void> _processCashOnDelivery(Payment payment) async {
    // Cash on delivery is always accepted but completed on delivery
    await Future.delayed(const Duration(seconds: 1));
    
    _updatePayment(payment.id,
      status: PaymentStatus.pending,
      metadata: {
        'paymentOnDelivery': true,
        'instructions': 'Payment will be collected upon delivery',
      },
    );
  }

  void _updatePaymentStatus(String paymentId, PaymentStatus status) {
    final index = _payments.indexWhere((payment) => payment.id == paymentId);
    if (index >= 0) {
      _payments[index] = _payments[index].copyWith(status: status);
      
      if (_currentPayment?.id == paymentId) {
        _currentPayment = _payments[index];
      }
      
      notifyListeners();
    }
  }

  void _updatePayment(String paymentId, {
    PaymentStatus? status,
    String? transactionReference,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    final index = _payments.indexWhere((payment) => payment.id == paymentId);
    if (index >= 0) {
      _payments[index] = _payments[index].copyWith(
        status: status,
        transactionReference: transactionReference,
        completedAt: completedAt,
        errorMessage: errorMessage,
        metadata: metadata,
      );
      
      if (_currentPayment?.id == paymentId) {
        _currentPayment = _payments[index];
      }
      
      notifyListeners();
    }
  }

  Payment? getPaymentByOrderId(String orderId) {
    try {
      return _payments.firstWhere((payment) => payment.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  Future<bool> retryPayment(String paymentId) async {
    final payment = _payments.firstWhere((p) => p.id == paymentId);
    
    if (payment.isFailed) {
      _updatePaymentStatus(paymentId, PaymentStatus.pending);
      await _processPayment(payment);
      return _payments.firstWhere((p) => p.id == paymentId).isCompleted;
    }
    
    return false;
  }

  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }

  String getPaymentInstructions(PaymentMethod method, {String? phoneNumber}) {
    switch (method) {
      case PaymentMethod.mtn:
        return 'Please confirm the payment on your MTN Mobile Money app or dial *303# to complete the transaction.';
      case PaymentMethod.airtel:
        return 'Please confirm the payment on your Airtel Money app or dial *432# to complete the transaction.';
      case PaymentMethod.zamtel:
        return 'Please confirm the payment on your Zamtel Kwacha app or dial *456# to complete the transaction.';
      case PaymentMethod.visa:
      case PaymentMethod.mastercard:
        return 'Please enter your card details to complete the payment securely.';
      case PaymentMethod.bankTransfer:
        return 'Please transfer the amount to the provided bank account details. Payment confirmation may take 1-2 hours.';
      case PaymentMethod.cashOnDelivery:
        return 'You will pay the delivery person when your order arrives. Please have the exact amount ready.';
    }
  }
}