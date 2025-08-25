import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/order.dart';
import '../../providers/payment_provider.dart';
import 'payment_processing_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Order order;
  
  const PaymentMethodScreen({
    super.key,
    required this.order,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethod? _selectedMethod;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Total:'),
                        Text(
                          widget.order.formattedTotal,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.order.totalItems} items',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment methods
            const Text(
              'Choose Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mobile Money Section
            _buildSectionHeader('Mobile Money', Icons.phone_android),
            _buildPaymentOption(PaymentMethod.mtn),
            _buildPaymentOption(PaymentMethod.airtel),
            _buildPaymentOption(PaymentMethod.zamtel),
            
            const SizedBox(height: 16),
            
            // Card Payment Section
            _buildSectionHeader('Card Payment', Icons.credit_card),
            _buildPaymentOption(PaymentMethod.visa),
            _buildPaymentOption(PaymentMethod.mastercard),
            
            const SizedBox(height: 16),
            
            // Other Methods Section
            _buildSectionHeader('Other Methods', Icons.account_balance),
            _buildPaymentOption(PaymentMethod.bankTransfer),
            _buildPaymentOption(PaymentMethod.cashOnDelivery),
            
            // Phone number input for mobile money
            if (_selectedMethod == PaymentMethod.mtn || 
                _selectedMethod == PaymentMethod.airtel || 
                _selectedMethod == PaymentMethod.zamtel) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Money Phone Number',
                  hintText: '+260 97 123 4567',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMethod != null ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Continue with ${_selectedMethod != null ? PaymentMethodInfo.getMethodInfo(_selectedMethod!).name : "Payment"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final methodInfo = PaymentMethodInfo.getMethodInfo(method);
    final isSelected = _selectedMethod == method;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<PaymentMethod>(
        value: method,
        groupValue: _selectedMethod,
        onChanged: methodInfo.isAvailable ? (value) {
          setState(() {
            _selectedMethod = value;
          });
        } : null,
        title: Row(
          children: [
            Text(
              methodInfo.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodInfo.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: methodInfo.isAvailable ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    methodInfo.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: methodInfo.isAvailable ? Colors.grey : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: Colors.blue,
        tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
      ),
    );
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) return;

    // Validate phone number for mobile money
    if ((_selectedMethod == PaymentMethod.mtn || 
         _selectedMethod == PaymentMethod.airtel || 
         _selectedMethod == PaymentMethod.zamtel) &&
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile money phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to payment processing
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(
          order: widget.order,
          paymentMethod: _selectedMethod!,
          phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        ),
      ),
    );
  }
}