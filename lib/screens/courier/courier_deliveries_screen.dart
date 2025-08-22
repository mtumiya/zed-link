import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/delivery.dart';

class CourierDeliveriesScreen extends StatelessWidget {
  const CourierDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Deliveries'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Available'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Consumer2<DeliveryProvider, AuthProvider>(
          builder: (context, deliveryProvider, authProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) return const Center(child: Text('Please login'));

            final myDeliveries = deliveryProvider.getDeliveriesForCourier(user.id);
            final activeDeliveries = myDeliveries.where((d) => d.isActive).toList();
            final completedDeliveries = myDeliveries.where((d) => d.isCompleted).toList();
            
            // Mock available deliveries (in real app, these would be unassigned deliveries)
            final availableDeliveries = deliveryProvider.getDeliveriesByStatus(DeliveryStatus.pending);

            return TabBarView(
              children: [
                _buildAvailableTab(context, availableDeliveries, deliveryProvider),
                _buildActiveTab(context, activeDeliveries),
                _buildCompletedTab(context, completedDeliveries),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvailableTab(BuildContext context, List<Delivery> deliveries, DeliveryProvider deliveryProvider) {
    if (deliveries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No available deliveries', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Check back later for new delivery requests', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return _buildAvailableDeliveryCard(context, deliveries[index], deliveryProvider);
      },
    );
  }

  Widget _buildActiveTab(BuildContext context, List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No active deliveries', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Accept available deliveries to get started', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return _buildActiveDeliveryCard(context, deliveries[index]);
      },
    );
  }

  Widget _buildCompletedTab(BuildContext context, List<Delivery> deliveries) {
    if (deliveries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No completed deliveries', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Your completed deliveries will appear here', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return _buildCompletedDeliveryCard(context, deliveries[index]);
      },
    );
  }

  Widget _buildAvailableDeliveryCard(BuildContext context, Delivery delivery, DeliveryProvider deliveryProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.orderId.substring(delivery.orderId.length - 6).toUpperCase()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  delivery.formattedDeliveryFee,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('From: ${delivery.pickupAddress}')),
              ],
            ),
            const SizedBox(height: 4),
            
            Row(
              children: [
                const Icon(Icons.flag, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('To: ${delivery.deliveryAddress}')),
              ],
            ),
            const SizedBox(height: 4),
            
            if (delivery.estimatedDistance != null)
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Distance: ${delivery.estimatedDistance!.toStringAsFixed(1)} km'),
                ],
              ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _acceptDelivery(context, delivery, deliveryProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept Delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveryCard(BuildContext context, Delivery delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CourierDeliveryDetailScreen(delivery: delivery),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${delivery.orderId.substring(delivery.orderId.length - 6).toUpperCase()}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(delivery.status),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                delivery.latestUpdate.message,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Client: ${delivery.clientName}'),
                ],
              ),
              
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(delivery.deliveryAddress)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedDeliveryCard(BuildContext context, Delivery delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.orderId.substring(delivery.orderId.length - 6).toUpperCase()}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  delivery.formattedDeliveryFee,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              'Delivered to ${delivery.clientName}',
              style: const TextStyle(color: Colors.grey),
            ),
            
            if (delivery.actualDeliveryTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed: ${_formatDateTime(delivery.actualDeliveryTime!)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DeliveryStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case DeliveryStatus.assigned:
        color = Colors.blue;
        text = 'Assigned';
        break;
      case DeliveryStatus.pickupReady:
        color = Colors.orange;
        text = 'Ready';
        break;
      case DeliveryStatus.pickedUp:
        color = Colors.purple;
        text = 'Picked Up';
        break;
      case DeliveryStatus.inTransit:
        color = Colors.indigo;
        text = 'In Transit';
        break;
      case DeliveryStatus.nearDelivery:
        color = Colors.teal;
        text = 'Near Delivery';
        break;
      default:
        color = Colors.grey;
        text = status.toString().split('.').last;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _acceptDelivery(BuildContext context, Delivery delivery, DeliveryProvider deliveryProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept Delivery'),
          content: Text('Do you want to accept this delivery for ${delivery.formattedDeliveryFee}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Actually assign delivery to current courier
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery accepted! Check your active deliveries.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class CourierDeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;
  
  const CourierDeliveryDetailScreen({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.latestUpdate.statusName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(delivery.latestUpdate.message),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Call client
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Client'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to location
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Update status buttons
            if (delivery.status == DeliveryStatus.assigned) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, DeliveryStatus.pickupReady),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark Ready for Pickup'),
                ),
              ),
            ] else if (delivery.status == DeliveryStatus.pickupReady) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, DeliveryStatus.pickedUp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark Picked Up'),
                ),
              ),
            ] else if (delivery.status == DeliveryStatus.pickedUp) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, DeliveryStatus.inTransit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Start Delivery'),
                ),
              ),
            ] else if (delivery.status == DeliveryStatus.inTransit) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus(context, DeliveryStatus.nearDelivery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Near Delivery Location'),
                ),
              ),
            ] else if (delivery.status == DeliveryStatus.nearDelivery) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeDelivery(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete Delivery'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Delivery information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Client', delivery.clientName),
                    _buildDetailRow('Phone', delivery.clientPhone),
                    _buildDetailRow('Pickup', delivery.pickupAddress),
                    _buildDetailRow('Delivery', delivery.deliveryAddress),
                    _buildDetailRow('Fee', delivery.formattedDeliveryFee),
                    if (delivery.specialInstructions != null)
                      _buildDetailRow('Instructions', delivery.specialInstructions!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateStatus(BuildContext context, DeliveryStatus newStatus) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    
    String message = '';
    switch (newStatus) {
      case DeliveryStatus.pickupReady:
        message = 'Package is ready for pickup';
        break;
      case DeliveryStatus.pickedUp:
        message = 'Package picked up from supplier';
        break;
      case DeliveryStatus.inTransit:
        message = 'Started delivery - package is on the way';
        break;
      case DeliveryStatus.nearDelivery:
        message = 'Approaching delivery location';
        break;
      default:
        message = 'Status updated';
    }
    
    deliveryProvider.updateDeliveryStatus(
      deliveryId: delivery.id,
      status: newStatus,
      message: message,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated: $message'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _completeDelivery(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Delivery'),
          content: const Text('Mark this delivery as completed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
                deliveryProvider.completeDelivery(deliveryId: delivery.id);
                
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to list
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delivery completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }
}