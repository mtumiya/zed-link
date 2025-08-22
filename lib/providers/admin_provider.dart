import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../models/rating.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class AdminProvider with ChangeNotifier {
  // This would typically connect to a backend API
  // For demo purposes, we'll use mock data and local state

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Dashboard Statistics
  AdminDashboardStats get dashboardStats {
    // In a real app, this would fetch from backend
    return AdminDashboardStats(
      totalUsers: 1245,
      totalOrders: 3456,
      totalDeliveries: 3200,
      totalRevenue: 89567.50,
      activeOrders: 89,
      pendingDeliveries: 45,
      completedDeliveries: 3155,
      cancelledOrders: 156,
      totalProducts: 234,
      totalSuppliers: 67,
      totalCouriers: 23,
      averageRating: 4.3,
      totalFeedbacks: 567,
      openFeedbacks: 23,
    );
  }

  // Recent Activity
  List<AdminActivity> get recentActivities {
    // Mock recent activities
    return [
      AdminActivity(
        id: '1',
        type: AdminActivityType.newOrder,
        title: 'New Order #ORD123',
        description: 'John Mwape placed an order worth K 145.50',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        priority: AdminActivityPriority.medium,
      ),
      AdminActivity(
        id: '2',
        type: AdminActivityType.deliveryCompleted,
        title: 'Delivery Completed',
        description: 'Grace Tembo completed delivery #DEL456',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        priority: AdminActivityPriority.low,
      ),
      AdminActivity(
        id: '3',
        type: AdminActivityType.paymentFailed,
        title: 'Payment Failed',
        description: 'Payment failed for order #ORD789 - requires attention',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        priority: AdminActivityPriority.high,
      ),
      AdminActivity(
        id: '4',
        type: AdminActivityType.newFeedback,
        title: 'New Complaint',
        description: 'Customer submitted complaint about delivery delay',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        priority: AdminActivityPriority.high,
      ),
      AdminActivity(
        id: '5',
        type: AdminActivityType.newUser,
        title: 'New User Registration',
        description: 'Peter Banda registered as a courier',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        priority: AdminActivityPriority.low,
      ),
    ];
  }

  // System Alerts
  List<AdminAlert> get systemAlerts {
    return [
      AdminAlert(
        id: '1',
        type: AdminAlertType.systemHealth,
        title: 'High Server Load',
        message: 'Server CPU usage is at 85%. Consider scaling resources.',
        severity: AdminAlertSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      AdminAlert(
        id: '2',
        type: AdminAlertType.business,
        title: 'Low Courier Availability',
        message: 'Only 3 couriers available in Lusaka Central area',
        severity: AdminAlertSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      AdminAlert(
        id: '3',
        type: AdminAlertType.financial,
        title: 'Daily Revenue Target',
        message: 'Today\'s revenue is 15% below target (K 12,450 vs K 14,650)',
        severity: AdminAlertSeverity.info,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // Performance Metrics
  AdminPerformanceMetrics get performanceMetrics {
    return AdminPerformanceMetrics(
      orderFulfillmentRate: 94.5,
      averageDeliveryTime: 45, // minutes
      customerSatisfactionScore: 4.3,
      courierUtilizationRate: 78.2,
      paymentSuccessRate: 89.1,
      appCrashRate: 0.02,
      apiResponseTime: 234, // milliseconds
    );
  }

  // User Management
  Future<List<User>> getUsers({
    UserRole? role,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data
      List<User> users = _generateMockUsers();
      
      if (role != null) {
        users = users.where((user) => user.role == role).toList();
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        users = users.where((user) =>
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.phoneNumber.contains(searchQuery)
        ).toList();
      }
      
      // Paginate
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex >= users.length) return [];
      
      return users.sublist(
        startIndex,
        endIndex > users.length ? users.length : endIndex,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    // Simulate API call to update user status
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  Future<void> verifyUser(String userId) async {
    // Simulate API call to verify user
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  // Order Management
  Future<List<Order>> getOrders({
    OrderStatus? status,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Get mock orders and filter them
      List<Order> orders = _generateMockOrders();
      
      if (status != null) {
        orders = orders.where((order) => order.status == status).toList();
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        orders = orders.where((order) =>
          order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.clientName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          order.clientPhone.contains(searchQuery)
        ).toList();
      }
      
      // Apply date filtering if provided
      if (startDate != null && endDate != null) {
        orders = orders.where((order) =>
          order.createdAt.isAfter(startDate) && order.createdAt.isBefore(endDate)
        ).toList();
      }
      
      // Paginate
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      if (startIndex >= orders.length) return [];
      
      return orders.sublist(
        startIndex,
        endIndex > orders.length ? orders.length : endIndex,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    // Simulate API call to update order status
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  // Feedback Management
  Future<void> respondToFeedback(String feedbackId, String response) async {
    // Simulate API call to respond to feedback
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  Future<void> updateFeedbackStatus(String feedbackId, FeedbackStatus status) async {
    // Simulate API call to update feedback status
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  // Analytics
  Map<String, double> getRevenueAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Mock revenue data by day
    return {
      'Mon': 12450.0,
      'Tue': 13200.0,
      'Wed': 11800.0,
      'Thu': 14500.0,
      'Fri': 16200.0,
      'Sat': 18300.0,
      'Sun': 15600.0,
    };
  }

  Map<String, int> getOrderStatusDistribution() {
    return {
      'Completed': 2800,
      'Processing': 45,
      'Pending': 89,
      'Cancelled': 156,
    };
  }

  Map<String, int> getUserRoleDistribution() {
    return {
      'Clients': 1078,
      'Couriers': 23,
      'Suppliers': 67,
      'Admins': 4,
    };
  }

  // Helper methods for mock data
  List<User> _generateMockUsers() {
    return [
      User(
        id: 'user1',
        phoneNumber: '+260971234567',
        name: 'John Mwape',
        role: UserRole.client,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'user2',
        phoneNumber: '+260977654321',
        name: 'Grace Tembo',
        role: UserRole.courier,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      User(
        id: 'user3',
        phoneNumber: '+260965432189',
        name: 'Peter Banda',
        role: UserRole.supplier,
        isVerified: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  List<Order> _generateMockOrders() {
    return [
      Order(
        id: 'ORD001',
        clientId: 'user1',
        clientName: 'John Mwape',
        clientPhone: '+260971234567',
        items: [
          CartItem(
            id: 'item1',
            product: Product(
              id: 'prod1',
              name: 'Fresh Tomatoes',
              description: 'Fresh red tomatoes from local farms',
              price: 25.00,
              unit: 'kg',
              imageUrl: '',
              category: ProductCategory.food,
              supplierId: 'sup1',
              supplierName: 'Green Valley Farm',
              stockQuantity: 100,
              createdAt: DateTime.now().subtract(const Duration(days: 5)),
              location: 'Lusaka',
            ),
            quantity: 2,
            addedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          CartItem(
            id: 'item2',
            product: Product(
              id: 'prod2',
              name: 'White Rice',
              description: 'Premium quality white rice',
              price: 45.00,
              unit: 'kg',
              imageUrl: '',
              category: ProductCategory.food,
              supplierId: 'sup2',
              supplierName: 'City Wholesalers',
              stockQuantity: 200,
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
              location: 'Lusaka',
            ),
            quantity: 1,
            addedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
        subtotal: 95.00,
        deliveryFee: 15.00,
        total: 110.00,
        status: OrderStatus.pending,
        deliveryMethod: DeliveryMethod.courierDelivery,
        deliveryAddress: '123 Kamwala Road, Lusaka',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'ORD002',
        clientId: 'user2',
        clientName: 'Grace Tembo',
        clientPhone: '+260977654321',
        items: [
          CartItem(
            id: 'item3',
            product: Product(
              id: 'prod3',
              name: 'Cooking Oil',
              description: 'Pure sunflower cooking oil',
              price: 75.00,
              unit: 'litre',
              imageUrl: '',
              category: ProductCategory.food,
              supplierId: 'sup3',
              supplierName: 'Food Plus',
              stockQuantity: 50,
              createdAt: DateTime.now().subtract(const Duration(days: 7)),
              location: 'Lusaka',
            ),
            quantity: 2,
            addedAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ],
        subtotal: 150.00,
        deliveryFee: 20.00,
        total: 170.00,
        status: OrderStatus.processing,
        deliveryMethod: DeliveryMethod.supplierDelivery,
        deliveryAddress: '45 Cairo Road, Lusaka',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Order(
        id: 'ORD003',
        clientId: 'user3',
        clientName: 'Peter Banda',
        clientPhone: '+260965432189',
        items: [
          CartItem(
            id: 'item4',
            product: Product(
              id: 'prod4',
              name: 'Bread',
              description: 'Fresh white bread',
              price: 12.00,
              unit: 'loaf',
              imageUrl: '',
              category: ProductCategory.food,
              supplierId: 'sup4',
              supplierName: 'Daily Bread',
              stockQuantity: 30,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              location: 'Lusaka',
            ),
            quantity: 3,
            addedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        subtotal: 36.00,
        deliveryFee: 10.00,
        total: 46.00,
        status: OrderStatus.delivered,
        deliveryMethod: DeliveryMethod.courierDelivery,
        deliveryAddress: '78 Great East Road, Lusaka',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 'ORD004',
        clientId: 'user4',
        clientName: 'Mary Phiri',
        clientPhone: '+260955555555',
        items: [
          CartItem(
            id: 'item5',
            product: Product(
              id: 'prod5',
              name: 'Sugar',
              description: 'Pure white sugar',
              price: 35.00,
              unit: 'kg',
              imageUrl: '',
              category: ProductCategory.food,
              supplierId: 'sup5',
              supplierName: 'Sweet Supply',
              stockQuantity: 150,
              createdAt: DateTime.now().subtract(const Duration(days: 10)),
              location: 'Lusaka',
            ),
            quantity: 2,
            addedAt: DateTime.now().subtract(const Duration(hours: 8)),
          ),
        ],
        subtotal: 70.00,
        deliveryFee: 15.00,
        total: 85.00,
        status: OrderStatus.cancelled,
        deliveryMethod: DeliveryMethod.courierDelivery,
        deliveryAddress: '12 Independence Avenue, Lusaka',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}

// Data Models for Admin Dashboard
class AdminDashboardStats {
  final int totalUsers;
  final int totalOrders;
  final int totalDeliveries;
  final double totalRevenue;
  final int activeOrders;
  final int pendingDeliveries;
  final int completedDeliveries;
  final int cancelledOrders;
  final int totalProducts;
  final int totalSuppliers;
  final int totalCouriers;
  final double averageRating;
  final int totalFeedbacks;
  final int openFeedbacks;

  AdminDashboardStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalDeliveries,
    required this.totalRevenue,
    required this.activeOrders,
    required this.pendingDeliveries,
    required this.completedDeliveries,
    required this.cancelledOrders,
    required this.totalProducts,
    required this.totalSuppliers,
    required this.totalCouriers,
    required this.averageRating,
    required this.totalFeedbacks,
    required this.openFeedbacks,
  });

  String get formattedRevenue => 'K ${totalRevenue.toStringAsFixed(2)}';
}

class AdminActivity {
  final String id;
  final AdminActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final AdminActivityPriority priority;

  AdminActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.priority,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
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
}

class AdminAlert {
  final String id;
  final AdminAlertType type;
  final String title;
  final String message;
  final AdminAlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  AdminAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });
}

class AdminPerformanceMetrics {
  final double orderFulfillmentRate;
  final int averageDeliveryTime;
  final double customerSatisfactionScore;
  final double courierUtilizationRate;
  final double paymentSuccessRate;
  final double appCrashRate;
  final int apiResponseTime;

  AdminPerformanceMetrics({
    required this.orderFulfillmentRate,
    required this.averageDeliveryTime,
    required this.customerSatisfactionScore,
    required this.courierUtilizationRate,
    required this.paymentSuccessRate,
    required this.appCrashRate,
    required this.apiResponseTime,
  });
}

enum AdminActivityType {
  newOrder,
  deliveryCompleted,
  paymentFailed,
  newFeedback,
  newUser,
  systemUpdate,
}

enum AdminActivityPriority {
  low,
  medium,
  high,
  urgent,
}

enum AdminAlertType {
  systemHealth,
  business,
  financial,
  security,
}

enum AdminAlertSeverity {
  info,
  warning,
  error,
  critical,
}