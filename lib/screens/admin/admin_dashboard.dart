import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/notification_provider.dart';
import '../shared/notifications_screen.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_feedback_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zed Link - Admin'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingsScreen(),
                  ),
                );
              } else if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<AuthProvider, AdminProvider>(
        builder: (context, authProvider, adminProvider, child) {
          final user = authProvider.currentUser;
          final stats = adminProvider.dashboardStats;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'Admin'}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'System Administrator',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Key Metrics
                const Text(
                  'Key Metrics',
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
                    _buildMetricCard('Total Users', '${stats.totalUsers}', Icons.people, Colors.blue),
                    _buildMetricCard('Active Orders', '${stats.activeOrders}', Icons.shopping_cart, Colors.orange),
                    _buildMetricCard('Today\'s Revenue', stats.formattedRevenue, Icons.monetization_on, Colors.green),
                    _buildMetricCard('Avg. Rating', '${stats.averageRating}/5', Icons.star, Colors.amber),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
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
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionCard(
                      'Manage Users',
                      Icons.people_alt,
                      Colors.blue,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminUsersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Order Management',
                      Icons.assignment,
                      Colors.orange,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Feedback & Support',
                      Icons.support_agent,
                      Colors.green,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminFeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Analytics',
                      Icons.analytics,
                      Colors.purple,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminAnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: adminProvider.recentActivities
                        .take(5)
                        .map((activity) => _buildActivityTile(activity))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // System Alerts
                if (adminProvider.systemAlerts.isNotEmpty) ...[
                  const Text(
                    'System Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: adminProvider.systemAlerts
                        .map((alert) => _buildAlertCard(alert, context))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Performance Overview
                const Text(
                  'Performance Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildPerformanceRow('Order Fulfillment', '${adminProvider.performanceMetrics.orderFulfillmentRate}%'),
                        _buildPerformanceRow('Avg. Delivery Time', '${adminProvider.performanceMetrics.averageDeliveryTime} min'),
                        _buildPerformanceRow('Customer Satisfaction', '${adminProvider.performanceMetrics.customerSatisfactionScore}/5'),
                        _buildPerformanceRow('Payment Success Rate', '${adminProvider.performanceMetrics.paymentSuccessRate}%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
                fontSize: 20,
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

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(AdminActivity activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getActivityColor(activity.type).withValues(alpha: 0.2),
        child: Icon(
          _getActivityIcon(activity.type),
          color: _getActivityColor(activity.type),
          size: 20,
        ),
      ),
      title: Text(activity.title),
      subtitle: Text(activity.description),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            activity.timeAgo,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(activity.priority).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              activity.priority.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: _getPriorityColor(activity.priority),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AdminAlert alert, BuildContext context) {
    return Card(
      color: _getAlertColor(alert.severity).withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(
          _getAlertIcon(alert.severity),
          color: _getAlertColor(alert.severity),
        ),
        title: Text(alert.title),
        subtitle: Text(alert.message),
        trailing: IconButton(
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Alert dismissed'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(AdminActivityType type) {
    switch (type) {
      case AdminActivityType.newOrder:
        return Colors.blue;
      case AdminActivityType.deliveryCompleted:
        return Colors.green;
      case AdminActivityType.paymentFailed:
        return Colors.red;
      case AdminActivityType.newFeedback:
        return Colors.orange;
      case AdminActivityType.newUser:
        return Colors.purple;
      case AdminActivityType.systemUpdate:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(AdminActivityType type) {
    switch (type) {
      case AdminActivityType.newOrder:
        return Icons.shopping_cart;
      case AdminActivityType.deliveryCompleted:
        return Icons.local_shipping;
      case AdminActivityType.paymentFailed:
        return Icons.payment;
      case AdminActivityType.newFeedback:
        return Icons.feedback;
      case AdminActivityType.newUser:
        return Icons.person_add;
      case AdminActivityType.systemUpdate:
        return Icons.system_update;
    }
  }

  Color _getPriorityColor(AdminActivityPriority priority) {
    switch (priority) {
      case AdminActivityPriority.low:
        return Colors.green;
      case AdminActivityPriority.medium:
        return Colors.orange;
      case AdminActivityPriority.high:
        return Colors.red;
      case AdminActivityPriority.urgent:
        return Colors.deepOrange;
    }
  }

  Color _getAlertColor(AdminAlertSeverity severity) {
    switch (severity) {
      case AdminAlertSeverity.info:
        return Colors.blue;
      case AdminAlertSeverity.warning:
        return Colors.orange;
      case AdminAlertSeverity.error:
        return Colors.red;
      case AdminAlertSeverity.critical:
        return Colors.deepOrange;
    }
  }

  IconData _getAlertIcon(AdminAlertSeverity severity) {
    switch (severity) {
      case AdminAlertSeverity.info:
        return Icons.info;
      case AdminAlertSeverity.warning:
        return Icons.warning;
      case AdminAlertSeverity.error:
        return Icons.error;
      case AdminAlertSeverity.critical:
        return Icons.dangerous;
    }
  }
}