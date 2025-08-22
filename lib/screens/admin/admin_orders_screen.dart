import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/order.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final statuses = [null, OrderStatus.pending, OrderStatus.processing, OrderStatus.delivered, OrderStatus.cancelled];
    _selectedStatus = statuses[_tabController.index];
    // _loadOrders(); // Would load orders based on status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Pending'),
            Tab(text: 'Processing'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final stats = adminProvider.dashboardStats;
          
          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search orders by ID or customer...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (value == _searchController.text) {
                        setState(() {});
                      }
                    });
                  },
                ),
              ),

              // Order Statistics
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total Orders', '${stats.totalOrders}', Icons.shopping_cart, Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Active', '${stats.activeOrders}', Icons.pending, Colors.orange),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Completed', '${stats.completedDeliveries}', Icons.check_circle, Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Cancelled', '${stats.cancelledOrders}', Icons.cancel, Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Orders List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersList(null),
                    _buildOrdersList(OrderStatus.pending),
                    _buildOrdersList(OrderStatus.processing),
                    _buildOrdersList(OrderStatus.delivered),
                    _buildOrdersList(OrderStatus.cancelled),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrderStatus? status) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return FutureBuilder<List<Order>>(
          future: adminProvider.getOrders(
            status: status,
            searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
            }

            final orders = snapshot.data ?? [];

            if (orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No orders found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, adminProvider);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Order order, AdminProvider adminProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getOrderStatusColor(order.status),
          child: Text(
            order.id.substring(0, 3).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Order #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getOrderStatusColor(order.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.statusName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getOrderStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.clientName}'),
            Text('Total: ${order.formattedTotal}'),
            Text('Created: ${order.createdAt.toString().substring(0, 16)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(order.clientPhone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.deliveryAddress)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(order.deliveryMethodName),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Order Items
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.quantity}x ${item.product.name}')),
                      Text(item.formattedTotalPrice),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(order.formattedTotal, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons
                if (order.status == OrderStatus.pending) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order.id, OrderStatus.confirmed, adminProvider),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order.id, OrderStatus.cancelled, adminProvider),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else if (order.status == OrderStatus.confirmed) ...[
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, OrderStatus.processing, adminProvider),
                    icon: const Icon(Icons.build, size: 16),
                    label: const Text('Start Processing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ] else if (order.status == OrderStatus.processing) ...[
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, OrderStatus.shipped, adminProvider),
                    icon: const Icon(Icons.local_shipping, size: 16),
                    label: const Text('Mark as Shipped'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus status, AdminProvider adminProvider) async {
    try {
      await adminProvider.updateOrderStatus(orderId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${status.toString().split('.').last}'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}