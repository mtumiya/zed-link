import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/delivery.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Deliveries'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<DeliveryProvider, AuthProvider>(
        builder: (context, deliveryProvider, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) return const Center(child: Text('Please login'));

          final deliveries = deliveryProvider.getDeliveriesForClient(user.id);

          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No deliveries yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your delivery tracking will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => deliveryProvider.refreshDeliveries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                return _buildDeliveryCard(context, deliveries[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Delivery delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DeliveryDetailScreen(delivery: delivery),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${delivery.orderId.substring(delivery.orderId.length - 6).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(delivery.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Courier info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Courier: ${delivery.courierName}'),
                ],
              ),
              const SizedBox(height: 4),
              
              // Latest update
              Row(
                children: [
                  const Icon(Icons.update, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      delivery.latestUpdate.message,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Time info
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(delivery.latestUpdate.timestamp),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              if (delivery.estimatedDeliveryTime != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Est. delivery: ${_formatEstimatedTime(delivery.estimatedDeliveryTime!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(DeliveryStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case DeliveryStatus.pending:
      case DeliveryStatus.assigned:
        color = Colors.orange;
        text = 'Assigned';
        break;
      case DeliveryStatus.pickupReady:
      case DeliveryStatus.pickedUp:
        color = Colors.blue;
        text = 'Picked Up';
        break;
      case DeliveryStatus.inTransit:
      case DeliveryStatus.nearDelivery:
        color = Colors.purple;
        text = 'In Transit';
        break;
      case DeliveryStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case DeliveryStatus.failed:
      case DeliveryStatus.cancelled:
        color = Colors.red;
        text = 'Failed';
        break;
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatEstimatedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m';
    } else {
      return 'Very soon';
    }
  }
}

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;
  
  const DeliveryDetailScreen({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Details'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Call courier
            },
            icon: const Icon(Icons.phone),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              color: _getStatusColor(delivery.status).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(delivery.status),
                      color: _getStatusColor(delivery.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delivery.latestUpdate.statusName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(delivery.status),
                            ),
                          ),
                          Text(
                            delivery.latestUpdate.message,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Delivery details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Order ID', delivery.orderId),
                    _buildDetailRow('Courier', delivery.courierName),
                    _buildDetailRow('Phone', delivery.courierPhone),
                    _buildDetailRow('Pickup', delivery.pickupAddress),
                    _buildDetailRow('Delivery', delivery.deliveryAddress),
                    if (delivery.estimatedDistance != null)
                      _buildDetailRow('Distance', '${delivery.estimatedDistance!.toStringAsFixed(1)} km'),
                    _buildDetailRow('Fee', delivery.formattedDeliveryFee),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Timeline
            const Text(
              'Delivery Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...delivery.updates.map((update) => _buildTimelineItem(update)),
            
            const SizedBox(height: 24),
            
            // Action buttons
            if (delivery.isActive) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Contact courier
                  },
                  icon: const Icon(Icons.phone),
                  label: Text('Call ${delivery.courierName}'),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Get help/support
                },
                icon: const Icon(Icons.help),
                label: const Text('Get Help'),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(DeliveryUpdate update) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(update.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(update.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
      case DeliveryStatus.assigned:
        return Colors.orange;
      case DeliveryStatus.pickupReady:
      case DeliveryStatus.pickedUp:
        return Colors.blue;
      case DeliveryStatus.inTransit:
      case DeliveryStatus.nearDelivery:
        return Colors.purple;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.failed:
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Icons.schedule;
      case DeliveryStatus.assigned:
        return Icons.assignment_ind;
      case DeliveryStatus.pickupReady:
        return Icons.inventory;
      case DeliveryStatus.pickedUp:
        return Icons.local_shipping;
      case DeliveryStatus.inTransit:
        return Icons.directions;
      case DeliveryStatus.nearDelivery:
        return Icons.near_me;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.failed:
        return Icons.error;
      case DeliveryStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}