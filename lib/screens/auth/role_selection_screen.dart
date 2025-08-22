import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class RoleSelectionScreen extends StatefulWidget {
  final String phoneNumber;
  
  const RoleSelectionScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? selectedRole;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _completeRegistration() async {
    if (_formKey.currentState!.validate() && selectedRole != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.completeUserRegistration(
        name: _nameController.text.trim(),
        role: selectedRole!,
      );
      
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your role'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Phone: ${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Name input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Role selection
                const Text(
                  'Select your role:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildRoleOption(
                  UserRole.client,
                  'Client',
                  'Order products and services',
                  Icons.shopping_cart,
                ),
                _buildRoleOption(
                  UserRole.supplier,
                  'Supplier/Producer',
                  'Sell products, manage inventory',
                  Icons.store,
                ),
                _buildRoleOption(
                  UserRole.courier,
                  'Courier/Driver',
                  'Deliver packages and earn money',
                  Icons.delivery_dining,
                ),
                
                const Spacer(),
                
                // Complete registration button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _completeRegistration,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(UserRole role, String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<UserRole>(
        value: role,
        groupValue: selectedRole,
        onChanged: (UserRole? value) {
          setState(() {
            selectedRole = value;
          });
        },
        title: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(description),
        ),
        activeColor: Colors.blue,
      ),
    );
  }
}