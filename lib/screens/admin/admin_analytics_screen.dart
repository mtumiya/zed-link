import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = 'This Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              'Today',
              'This Week',
              'This Month',
              'Last 3 Months',
              'This Year',
            ].map((period) => PopupMenuItem(
              value: period,
              child: Text(period),
            )).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final stats = adminProvider.dashboardStats;
          final metrics = adminProvider.performanceMetrics;
          final revenueData = adminProvider.getRevenueAnalytics(
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now(),
          );
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Overview
                const Text(
                  'Revenue Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildRevenueCard('Total Revenue', stats.formattedRevenue, Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRevenueCard('Avg. Order Value', 'K 145.50', Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Revenue Chart Placeholder
                Card(
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Daily Revenue Trend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: revenueData.entries.map((entry) {
                              final maxRevenue = revenueData.values.reduce((a, b) => a > b ? a : b);
                              final height = (entry.value / maxRevenue) * 120;
                              
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'K${(entry.value / 1000).toStringAsFixed(1)}k',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 30,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Business Metrics
                const Text(
                  'Business Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard('Order Fulfillment', '${metrics.orderFulfillmentRate}%', Icons.check_circle, Colors.green),
                    _buildMetricCard('Customer Satisfaction', '${metrics.customerSatisfactionScore}/5', Icons.star, Colors.amber),
                    _buildMetricCard('Avg. Delivery Time', '${metrics.averageDeliveryTime} min', Icons.timer, Colors.orange),
                    _buildMetricCard('Payment Success', '${metrics.paymentSuccessRate}%', Icons.payment, Colors.blue),
                  ],
                ),
                const SizedBox(height: 24),

                // Distribution Charts
                Row(
                  children: [
                    Expanded(
                      child: _buildDistributionCard(
                        'Order Status',
                        adminProvider.getOrderStatusDistribution(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDistributionCard(
                        'User Roles',
                        adminProvider.getUserRoleDistribution(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Export Options
                const Text(
                  'Export Reports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Revenue report exported successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Revenue Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User activity report exported successfully'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('User Activity'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionCard(String title, Map<String, int> data) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in data.entries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${(entry.value / total * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDistributionColor(entry.key),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDistributionColor(String key) {
    switch (key.toLowerCase()) {
      case 'completed':
      case 'clients':
        return Colors.green;
      case 'processing':
      case 'couriers':
        return Colors.orange;
      case 'pending':
      case 'suppliers':
        return Colors.blue;
      case 'cancelled':
      case 'admins':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}