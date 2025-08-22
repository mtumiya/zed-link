import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'client/client_dashboard.dart';
import 'supplier/supplier_dashboard.dart';
import 'courier/courier_dashboard.dart';
import 'admin/admin_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Route to role-specific dashboard
        switch (user.role) {
          case UserRole.client:
            return const ClientDashboard();
          case UserRole.supplier:
            return const SupplierDashboard();
          case UserRole.courier:
            return const CourierDashboard();
          case UserRole.admin:
            return const AdminDashboard();
        }
      },
    );
  }
}