import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/delivery.dart';
import '../models/order.dart';
import '../models/user.dart';

class DeliveryProvider with ChangeNotifier {
  List<Delivery> _deliveries = [];
  List<User> _availableCouriers = [];
  bool _isLoading = false;
  Function(Delivery, DeliveryStatus)? _onDeliveryStatusChanged;

  List<Delivery> get deliveries => _deliveries;
  List<User> get availableCouriers => _availableCouriers;
  bool get isLoading => _isLoading;

  List<Delivery> get activeDeliveries => 
      _deliveries.where((d) => d.isActive).toList();

  List<Delivery> get completedDeliveries => 
      _deliveries.where((d) => d.isCompleted).toList();

  void setOnDeliveryStatusChangedCallback(Function(Delivery, DeliveryStatus) callback) {
    _onDeliveryStatusChanged = callback;
  }

  DeliveryProvider() {
    _initializeMockCouriers();
  }

  void _initializeMockCouriers() {
    _availableCouriers = [
      User(
        id: 'courier1',
        phoneNumber: '+260971234567',
        name: 'John Mwape',
        role: UserRole.courier,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'courier2',
        phoneNumber: '+260977654321',
        name: 'Grace Tembo',
        role: UserRole.courier,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      User(
        id: 'courier3',
        phoneNumber: '+260965432189',
        name: 'Peter Banda',
        role: UserRole.courier,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  Future<Delivery> createDelivery({
    required Order order,
    required String pickupAddress,
    String? specialInstructions,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate finding nearest courier
      await Future.delayed(const Duration(seconds: 2));
      
      final courier = await _assignCourier();
      
      final delivery = Delivery(
        id: 'del_${DateTime.now().millisecondsSinceEpoch}',
        orderId: order.id,
        courierId: courier.id,
        courierName: courier.name,
        courierPhone: courier.phoneNumber,
        clientId: order.clientId,
        clientName: order.clientName,
        clientPhone: order.clientPhone,
        pickupAddress: pickupAddress,
        deliveryAddress: order.deliveryAddress,
        deliveryFee: order.deliveryFee,
        estimatedDistance: _calculateDistance(),
        createdAt: DateTime.now(),
        estimatedPickupTime: DateTime.now().add(const Duration(minutes: 30)),
        estimatedDeliveryTime: DateTime.now().add(const Duration(hours: 2)),
        specialInstructions: specialInstructions,
        status: DeliveryStatus.assigned,
        updates: [
          DeliveryUpdate(
            id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
            status: DeliveryStatus.assigned,
            message: 'Delivery assigned to ${courier.name}',
            timestamp: DateTime.now(),
          ),
        ],
      );

      _deliveries.add(delivery);
      
      // Start automatic status updates
      _startDeliverySimulation(delivery.id);
      
      return delivery;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User> _assignCourier() async {
    // Simple assignment - in real app would consider location, availability, etc.
    final random = Random();
    return _availableCouriers[random.nextInt(_availableCouriers.length)];
  }

  double _calculateDistance() {
    // Mock distance calculation - in real app would use actual coordinates
    final random = Random();
    return 2.0 + random.nextDouble() * 20.0; // 2-22 km
  }

  void _startDeliverySimulation(String deliveryId) {
    // Simulate delivery progress over time
    Future.delayed(const Duration(minutes: 5), () {
      _addDeliveryUpdate(deliveryId, DeliveryStatus.pickupReady, 
          'Package is ready for pickup at supplier location');
    });
    
    Future.delayed(const Duration(minutes: 15), () {
      _addDeliveryUpdate(deliveryId, DeliveryStatus.pickedUp, 
          'Package picked up from supplier');
    });
    
    Future.delayed(const Duration(minutes: 30), () {
      _addDeliveryUpdate(deliveryId, DeliveryStatus.inTransit, 
          'Package is on the way to delivery address');
    });
    
    Future.delayed(const Duration(minutes: 45), () {
      _addDeliveryUpdate(deliveryId, DeliveryStatus.nearDelivery, 
          'Courier is approaching delivery location');
    });
    
    Future.delayed(const Duration(hours: 1), () {
      _addDeliveryUpdate(deliveryId, DeliveryStatus.delivered, 
          'Package delivered successfully');
    });
  }

  void _addDeliveryUpdate(String deliveryId, DeliveryStatus status, String message) {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index >= 0) {
      final delivery = _deliveries[index];
      final update = DeliveryUpdate(
        id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
        status: status,
        message: message,
        timestamp: DateTime.now(),
        location: _generateMockLocation(),
      );
      
      final updatedDelivery = delivery.copyWith(
        status: status,
        updates: [...delivery.updates, update],
        actualPickupTime: status == DeliveryStatus.pickedUp ? DateTime.now() : delivery.actualPickupTime,
        actualDeliveryTime: status == DeliveryStatus.delivered ? DateTime.now() : delivery.actualDeliveryTime,
      );
      
      _deliveries[index] = updatedDelivery;
      
      // Trigger notification callback
      _onDeliveryStatusChanged?.call(updatedDelivery, status);
      
      notifyListeners();
    }
  }

  DeliveryLocation _generateMockLocation() {
    // Mock Lusaka coordinates with small random variations
    final random = Random();
    return DeliveryLocation(
      latitude: -15.4067 + (random.nextDouble() - 0.5) * 0.1,
      longitude: 28.2871 + (random.nextDouble() - 0.5) * 0.1,
      address: 'Lusaka, Zambia',
      timestamp: DateTime.now(),
    );
  }

  Delivery? getDeliveryByOrderId(String orderId) {
    try {
      return _deliveries.firstWhere((delivery) => delivery.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  Delivery? getDeliveryById(String deliveryId) {
    try {
      return _deliveries.firstWhere((delivery) => delivery.id == deliveryId);
    } catch (e) {
      return null;
    }
  }

  List<Delivery> getDeliveriesForClient(String clientId) {
    return _deliveries.where((delivery) => delivery.clientId == clientId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Delivery> getDeliveriesForCourier(String courierId) {
    return _deliveries.where((delivery) => delivery.courierId == courierId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Delivery> getDeliveriesByStatus(DeliveryStatus status) {
    return _deliveries.where((delivery) => delivery.status == status).toList();
  }

  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
    required String message,
    DeliveryLocation? location,
    String? proofImageUrl,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index >= 0) {
      final delivery = _deliveries[index];
      final update = DeliveryUpdate(
        id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
        status: status,
        message: message,
        timestamp: DateTime.now(),
        location: location,
        imageUrl: proofImageUrl,
      );
      
      final updatedDelivery = delivery.copyWith(
        status: status,
        updates: [...delivery.updates, update],
        proofOfDeliveryUrl: proofImageUrl ?? delivery.proofOfDeliveryUrl,
      );
      
      _deliveries[index] = updatedDelivery;
      notifyListeners();
    }
  }

  Future<void> cancelDelivery(String deliveryId, String reason) async {
    await updateDeliveryStatus(
      deliveryId: deliveryId,
      status: DeliveryStatus.cancelled,
      message: 'Delivery cancelled: $reason',
    );
  }

  Future<void> markDeliveryFailed(String deliveryId, String reason) async {
    await updateDeliveryStatus(
      deliveryId: deliveryId,
      status: DeliveryStatus.failed,
      message: 'Delivery failed: $reason',
    );
  }

  Future<void> completeDelivery({
    required String deliveryId,
    String? proofImageUrl,
  }) async {
    final index = _deliveries.indexWhere((d) => d.id == deliveryId);
    if (index >= 0) {
      final delivery = _deliveries[index];
      final updatedDelivery = delivery.copyWith(
        status: DeliveryStatus.delivered,
        actualDeliveryTime: DateTime.now(),
        proofOfDeliveryUrl: proofImageUrl,
        updates: [
          ...delivery.updates,
          DeliveryUpdate(
            id: 'upd_${DateTime.now().millisecondsSinceEpoch}',
            status: DeliveryStatus.delivered,
            message: 'Package delivered successfully',
            timestamp: DateTime.now(),
            location: _generateMockLocation(),
            imageUrl: proofImageUrl,
          ),
        ],
      );
      
      _deliveries[index] = updatedDelivery;
      notifyListeners();
    }
  }

  Future<void> refreshDeliveries() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }

  void clearDeliveries() {
    _deliveries.clear();
    notifyListeners();
  }
}