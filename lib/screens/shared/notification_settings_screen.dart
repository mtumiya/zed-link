import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final preferences = context.read<NotificationProvider>().preferences;
    _whatsappController.text = preferences.whatsappNumber ?? '';
    _emailController.text = preferences.emailAddress ?? '';
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return TextButton(
                onPressed: () {
                  notificationProvider.clearAllNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications cleared')),
                  );
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final preferences = notificationProvider.preferences;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Channel Settings
                const Text(
                  'Notification Channels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose how you want to receive notifications',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('In-App Notifications'),
                        subtitle: const Text('Show notifications within the app'),
                        value: preferences.enableInApp,
                        onChanged: (value) {
                          _updatePreferences(
                            preferences.copyWith(enableInApp: value),
                            notificationProvider,
                          );
                        },
                        secondary: const Icon(Icons.mobile_friendly),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('SMS Notifications'),
                        subtitle: const Text('Receive important updates via SMS'),
                        value: preferences.enableSMS,
                        onChanged: (value) {
                          _updatePreferences(
                            preferences.copyWith(enableSMS: value),
                            notificationProvider,
                          );
                        },
                        secondary: const Icon(Icons.sms),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('WhatsApp Notifications'),
                        subtitle: const Text('Get delivery updates on WhatsApp'),
                        value: preferences.enableWhatsApp,
                        onChanged: (value) {
                          _updatePreferences(
                            preferences.copyWith(enableWhatsApp: value),
                            notificationProvider,
                          );
                        },
                        secondary: const Icon(Icons.message),
                      ),
                      if (preferences.enableWhatsApp) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: _whatsappController,
                            decoration: const InputDecoration(
                              labelText: 'WhatsApp Number',
                              hintText: '+260 XXX XXX XXX',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _updatePreferences(
                                preferences.copyWith(whatsappNumber: value.isEmpty ? null : value),
                                notificationProvider,
                              );
                            },
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive order summaries via email'),
                        value: preferences.enableEmail,
                        onChanged: (value) {
                          _updatePreferences(
                            preferences.copyWith(enableEmail: value),
                            notificationProvider,
                          );
                        },
                        secondary: const Icon(Icons.email),
                      ),
                      if (preferences.enableEmail) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'your.email@example.com',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _updatePreferences(
                                preferences.copyWith(emailAddress: value.isEmpty ? null : value),
                                notificationProvider,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Notification Types
                const Text(
                  'Notification Types',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Control which types of notifications you receive',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      _buildNotificationTypeTile(
                        'Order Confirmations',
                        'When your orders are confirmed',
                        NotificationType.orderConfirmation,
                        preferences,
                        notificationProvider,
                        Icons.check_circle,
                      ),
                      const Divider(height: 1),
                      _buildNotificationTypeTile(
                        'Payment Updates',
                        'Payment confirmations and reminders',
                        NotificationType.paymentConfirmation,
                        preferences,
                        notificationProvider,
                        Icons.payment,
                      ),
                      const Divider(height: 1),
                      _buildNotificationTypeTile(
                        'Delivery Updates',
                        'Package pickup, transit, and delivery notifications',
                        NotificationType.deliveryAssigned,
                        preferences,
                        notificationProvider,
                        Icons.local_shipping,
                      ),
                      const Divider(height: 1),
                      _buildNotificationTypeTile(
                        'Supplier Updates',
                        'Product availability and supplier news',
                        NotificationType.supplierUpdate,
                        preferences,
                        notificationProvider,
                        Icons.store,
                      ),
                      const Divider(height: 1),
                      _buildNotificationTypeTile(
                        'Promotional Offers',
                        'Deals, discounts, and special offers',
                        NotificationType.promotional,
                        preferences,
                        notificationProvider,
                        Icons.local_offer,
                      ),
                      const Divider(height: 1),
                      _buildNotificationTypeTile(
                        'System Alerts',
                        'Important system updates and maintenance',
                        NotificationType.systemAlert,
                        preferences,
                        notificationProvider,
                        Icons.warning,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Statistics
                const Text(
                  'Statistics',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Notifications'),
                            Text(
                              '${notificationProvider.notifications.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Unread Notifications'),
                            Text(
                              '${notificationProvider.unreadCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildNotificationTypeTile(
    String title,
    String subtitle,
    NotificationType type,
    NotificationPreferences preferences,
    NotificationProvider provider,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: preferences.isTypeEnabled(type),
      onChanged: (value) {
        final newTypePreferences = Map<NotificationType, bool>.from(preferences.typePreferences);
        newTypePreferences[type] = value;
        
        _updatePreferences(
          preferences.copyWith(typePreferences: newTypePreferences),
          provider,
        );
      },
      secondary: Icon(icon),
    );
  }

  void _updatePreferences(NotificationPreferences newPreferences, NotificationProvider provider) {
    provider.updatePreferences(newPreferences);
  }
}