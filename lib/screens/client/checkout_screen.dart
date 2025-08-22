import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/order.dart';
import 'payment_method_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.courierDelivery;
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer3<CartProvider, AuthProvider, NotificationProvider>(
        builder: (context, cartProvider, authProvider, notificationProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  _buildOrderSummary(cartProvider),
                  const SizedBox(height: 24),
                  
                  // Delivery information
                  _buildDeliverySection(),
                  const SizedBox(height: 24),
                  
                  // Customer information
                  _buildCustomerSection(authProvider),
                  const SizedBox(height: 24),
                  
                  // Payment summary
                  _buildPaymentSummary(cartProvider),
                  const SizedBox(height: 24),
                  
                  // Place order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _placeOrder(context, cartProvider, authProvider, notificationProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Place Order - ${cartProvider.formattedTotal}',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Group items by supplier
            ...cartProvider.itemsBySupplier.entries.map((supplierGroup) {
              final supplierId = supplierGroup.key;
              final items = supplierGroup.value;
              final supplierName = items.first.product.supplierName;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplierName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          item.formattedTotalPrice,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Delivery method selection
            const Text(
              'Delivery Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            RadioListTile<DeliveryMethod>(
              value: DeliveryMethod.courierDelivery,
              groupValue: _selectedDeliveryMethod,
              onChanged: (value) {
                setState(() {
                  _selectedDeliveryMethod = value!;
                });
              },
              title: const Text('Courier Delivery'),
              subtitle: const Text('Delivered by our courier network'),
            ),
            
            RadioListTile<DeliveryMethod>(
              value: DeliveryMethod.supplierDelivery,
              groupValue: _selectedDeliveryMethod,
              onChanged: (value) {
                setState(() {
                  _selectedDeliveryMethod = value!;
                });
              },
              title: const Text('Supplier Delivery'),
              subtitle: const Text('Delivered by the supplier'),
            ),
            
            RadioListTile<DeliveryMethod>(
              value: DeliveryMethod.pickup,
              groupValue: _selectedDeliveryMethod,
              onChanged: (value) {
                setState(() {
                  _selectedDeliveryMethod = value!;
                });
              },
              title: const Text('Pickup'),
              subtitle: const Text('Pick up from supplier location'),
            ),
            
            const SizedBox(height: 16),
            
            // Delivery address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter your full address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your delivery address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Order notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Order Notes (Optional)',
                hintText: 'Any special instructions',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  user?.name ?? 'Unknown',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  user?.phoneNumber ?? 'Unknown',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(CartProvider cartProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildSummaryRow('Subtotal', cartProvider.formattedSubtotal),
            const SizedBox(height: 4),
            _buildSummaryRow('Delivery Fee', cartProvider.formattedDeliveryFee),
            const Divider(height: 16),
            _buildSummaryRow(
              'Total Amount',
              cartProvider.formattedTotal,
              isTotal: true,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.payment, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Multiple payment options available: Mobile Money, Cards, or Cash on Delivery',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.blue : Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cartProvider, AuthProvider authProvider, NotificationProvider notificationProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 2));

      final order = await cartProvider.createOrder(
        clientId: user.id,
        clientName: user.name,
        clientPhone: user.phoneNumber,
        deliveryAddress: _addressController.text.trim(),
        deliveryMethod: _selectedDeliveryMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Send order confirmation notification
      await notificationProvider.notifyOrderConfirmation(
        userId: user.id,
        order: order,
      );

      if (mounted) {
        // Navigate to payment selection
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentMethodScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}