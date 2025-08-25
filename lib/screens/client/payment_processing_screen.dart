import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/order.dart';
import '../../providers/payment_provider.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final Order order;
  final PaymentMethod paymentMethod;
  final String? phoneNumber;
  
  const PaymentProcessingScreen({
    super.key,
    required this.order,
    required this.paymentMethod,
    this.phoneNumber,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  Payment? _currentPayment;
  bool _hasInitiated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiatePayment();
    });
  }

  Future<void> _initiatePayment() async {
    if (_hasInitiated) return;
    _hasInitiated = true;

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    try {
      final payment = await paymentProvider.initiatePayment(
        order: widget.order,
        method: widget.paymentMethod,
        phoneNumber: widget.phoneNumber,
      );
      
      setState(() {
        _currentPayment = payment;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Processing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          final payment = _currentPayment ?? paymentProvider.currentPayment;
          
          if (payment == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing payment...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Payment status card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatusIcon(payment.status),
                        const SizedBox(height: 16),
                        Text(
                          _getStatusTitle(payment.status),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusDescription(payment.status, payment.method),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Payment details
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Amount', payment.formattedAmount),
                        _buildDetailRow('Method', PaymentMethodInfo.getMethodInfo(payment.method).name),
                        if (payment.phoneNumber != null)
                          _buildDetailRow('Phone', payment.phoneNumber!),
                        _buildDetailRow('Order ID', payment.orderId),
                        if (payment.transactionReference != null)
                          _buildDetailRow('Transaction ID', payment.transactionReference!),
                        _buildDetailRow('Status', payment.statusName),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Instructions
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          paymentProvider.getPaymentInstructions(
                            payment.method,
                            phoneNumber: payment.phoneNumber,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                if (payment.status == PaymentStatus.failed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _retryPayment(paymentProvider, payment.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Retry Payment'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                if (payment.status == PaymentStatus.completed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToOrders(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('View Order'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _goHome(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return const CircularProgressIndicator();
      case PaymentStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentStatus.failed:
      case PaymentStatus.cancelled:
        icon = Icons.error;
        color = Colors.red;
        break;
      case PaymentStatus.refunded:
        icon = Icons.undo;
        color = Colors.orange;
        break;
    }
    
    return Icon(icon, size: 64, color: color);
  }

  String _getStatusTitle(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Payment Initiated';
      case PaymentStatus.processing:
        return 'Processing Payment';
      case PaymentStatus.completed:
        return 'Payment Successful!';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
      case PaymentStatus.refunded:
        return 'Payment Refunded';
    }
  }

  String _getStatusDescription(PaymentStatus status, PaymentMethod method) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Please complete the payment process';
      case PaymentStatus.processing:
        return 'Your payment is being processed...';
      case PaymentStatus.completed:
        return 'Your payment has been received successfully';
      case PaymentStatus.failed:
        return 'Payment could not be completed. Please try again.';
      case PaymentStatus.cancelled:
        return 'Payment was cancelled';
      case PaymentStatus.refunded:
        return 'Payment has been refunded';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _retryPayment(PaymentProvider paymentProvider, String paymentId) async {
    final success = await paymentProvider.retryPayment(paymentId);
    
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retry failed. Please try a different payment method.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToOrders(BuildContext context) {
    // TODO: Navigate to orders screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order tracking coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}