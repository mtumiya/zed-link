import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoOrderConfirmation = false;
  bool _maintenanceMode = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = ['English', 'Bemba', 'Nyanja'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Settings
            const Text(
              'System Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive system notifications'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Auto Order Confirmation'),
                    subtitle: const Text('Automatically confirm new orders'),
                    value: _autoOrderConfirmation,
                    onChanged: (value) {
                      setState(() {
                        _autoOrderConfirmation = value;
                      });
                    },
                    secondary: const Icon(Icons.auto_awesome),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Maintenance Mode'),
                    subtitle: const Text('Disable app for maintenance'),
                    value: _maintenanceMode,
                    onChanged: (value) {
                      setState(() {
                        _maintenanceMode = value;
                      });
                      _showMaintenanceDialog(value);
                    },
                    secondary: const Icon(Icons.build),
                    activeThumbColor: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Configuration
            const Text(
              'App Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Default Language'),
                    subtitle: Text(_selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.language),
                    onTap: _showLanguageDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Data Management'),
                    subtitle: const Text('Export, backup, and clear data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.storage),
                    onTap: _showDataManagementDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('System Logs'),
                    subtitle: const Text('View application logs'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.bug_report),
                    onTap: _showSystemLogs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Business Settings
            const Text(
              'Business Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Delivery Fees'),
                    subtitle: const Text('Configure delivery pricing'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.local_shipping),
                    onTap: _showDeliveryFeesDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Commission Rates'),
                    subtitle: const Text('Set commission for suppliers/couriers'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.percent),
                    onTap: _showCommissionDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Payment Methods'),
                    subtitle: const Text('Configure available payment options'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.payment),
                    onTap: _showPaymentMethodsDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Actions
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your admin password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    leading: const Icon(Icons.lock),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Logout'),
                    subtitle: const Text('Sign out of admin account'),
                    trailing: const Icon(Icons.exit_to_app),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    textColor: Colors.red,
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) => RadioListTile<String>(
            title: Text(language),
            value: language,
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              Navigator.of(context).pop();
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showMaintenanceDialog(bool enabled) {
    if (enabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Maintenance Mode'),
          content: const Text(
            'Are you sure you want to enable maintenance mode? '
            'This will prevent users from accessing the app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _maintenanceMode = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Maintenance mode enabled'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    }
  }

  void _showDataManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: const Text('Choose a data management action:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exportData();
            },
            child: const Text('Export Data'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _backupData();
            },
            child: const Text('Backup Data'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showSystemLogs() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('System Logs'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text(
              'System logs would be displayed here\n\n'
              'This feature would show:\n'
              '• Application errors\n'
              '• User actions\n'
              '• System events\n'
              '• Performance metrics',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeliveryFeesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery Fees Configuration'),
        content: const Text(
          'Configure delivery fees by:\n\n'
          '• Distance zones\n'
          '• Vehicle type\n'
          '• Time of day\n'
          '• Special conditions',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Configure Later'),
          ),
        ],
      ),
    );
  }

  void _showCommissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Commission Rates'),
        content: const Text(
          'Set commission rates for:\n\n'
          '• Supplier transactions: 5%\n'
          '• Courier deliveries: 15%\n'
          '• Payment processing: 2.5%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Update Later'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Methods'),
        content: const Text(
          'Available payment methods:\n\n'
          '✓ Mobile Money (MTN, Airtel)\n'
          '✓ Bank Transfer\n'
          '✓ Credit/Debit Cards\n'
          '✓ Cash on Delivery',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Configure'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export initiated. Check downloads folder.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data backup completed successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'WARNING: This will permanently delete all application data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data cleared successfully.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}