import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification.dart';
import '../models/order.dart';
import '../models/delivery.dart';
import '../models/payment.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  NotificationPreferences _preferences = NotificationPreferences();
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<AppNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  NotificationPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  
  int get unreadCount => unreadNotifications.length;

  NotificationProvider() {
    _loadNotifications();
    _loadPreferences();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications');
    
    if (notificationsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(notificationsJson);
        _notifications = decoded.map((item) => AppNotification.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading notifications: $e');
      }
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = json.encode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('notifications', notificationsJson);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString('notification_preferences');
    
    if (preferencesJson != null) {
      try {
        _preferences = NotificationPreferences.fromJson(json.decode(preferencesJson));
        notifyListeners();
      } catch (e) {
        print('Error loading notification preferences: $e');
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = json.encode(_preferences.toJson());
    await prefs.setString('notification_preferences', preferencesJson);
  }

  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
    notifyListeners();
  }

  Future<AppNotification> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationPriority priority = NotificationPriority.medium,
    List<NotificationChannel>? channels,
    DateTime? scheduledAt,
  }) async {
    // Determine channels based on preferences and type
    final effectiveChannels = channels ?? _getDefaultChannels(type);
    
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      priority: priority,
      channels: effectiveChannels,
      createdAt: DateTime.now(),
      scheduledAt: scheduledAt,
    );

    _notifications.add(notification);
    await _saveNotifications();
    
    // Send notification through appropriate channels
    await _sendNotification(notification);
    
    notifyListeners();
    return notification;
  }

  List<NotificationChannel> _getDefaultChannels(NotificationType type) {
    List<NotificationChannel> channels = [NotificationChannel.inApp];
    
    if (!_preferences.isTypeEnabled(type)) {
      return []; // Type is disabled
    }
    
    // Add channels based on preferences and notification type
    if (_preferences.enableSMS) {
      switch (type) {
        case NotificationType.orderConfirmation:
        case NotificationType.paymentConfirmation:
        case NotificationType.deliveryAssigned:
        case NotificationType.deliveryCompleted:
          channels.add(NotificationChannel.sms);
          break;
        default:
          break;
      }
    }
    
    if (_preferences.enableWhatsApp && _preferences.whatsappNumber != null) {
      switch (type) {
        case NotificationType.orderConfirmation:
        case NotificationType.deliveryInTransit:
        case NotificationType.deliveryArriving:
        case NotificationType.deliveryCompleted:
          channels.add(NotificationChannel.whatsapp);
          break;
        default:
          break;
      }
    }
    
    return channels;
  }

  Future<void> _sendNotification(AppNotification notification) async {
    Map<NotificationChannel, bool> deliveryStatus = {};
    
    for (final channel in notification.channels) {
      try {
        switch (channel) {
          case NotificationChannel.inApp:
            deliveryStatus[channel] = true; // Always successful for in-app
            break;
          case NotificationChannel.sms:
            deliveryStatus[channel] = await _sendSMS(notification);
            break;
          case NotificationChannel.whatsapp:
            deliveryStatus[channel] = await _sendWhatsApp(notification);
            break;
          case NotificationChannel.email:
            deliveryStatus[channel] = await _sendEmail(notification);
            break;
        }
      } catch (e) {
        deliveryStatus[channel] = false;
        print('Failed to send notification via $channel: $e');
      }
    }
    
    // Update notification with delivery status
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      _notifications[index] = notification.copyWith(
        isSent: deliveryStatus.values.any((success) => success),
        deliveryStatus: deliveryStatus,
      );
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<bool> _sendSMS(AppNotification notification) async {
    // Simulate SMS sending
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock SMS content
    final smsBody = '${notification.title}\n${notification.body}\n\nZed Link - Order & Courier App';
    
    print('📱 SMS Sent: $smsBody');
    return true; // 95% success rate in simulation
  }

  Future<bool> _sendWhatsApp(AppNotification notification) async {
    // Simulate WhatsApp sending
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock WhatsApp message
    final whatsappMessage = '''
🔔 *${notification.title}*

${notification.body}

Track your order in the Zed Link app: https://zedlink.zm

_This is an automated message from Zed Link_
    ''';
    
    print('📲 WhatsApp Sent: $whatsappMessage');
    return true; // 90% success rate in simulation
  }

  Future<bool> _sendEmail(AppNotification notification) async {
    // Simulate email sending
    await Future.delayed(const Duration(milliseconds: 1200));
    
    print('📧 Email Sent: ${notification.title} - ${notification.body}');
    return true; // 98% success rate in simulation
  }

  // Convenience methods for creating specific notification types

  Future<void> notifyOrderConfirmation({
    required String userId,
    required Order order,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.orderConfirmation,
      title: 'Order Confirmed!',
      body: 'Your order #${order.id.substring(order.id.length - 6).toUpperCase()} has been confirmed and is being prepared.',
      data: {'orderId': order.id, 'total': order.total},
      priority: NotificationPriority.high,
    );
  }

  Future<void> notifyPaymentConfirmation({
    required String userId,
    required Payment payment,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.paymentConfirmation,
      title: 'Payment Received',
      body: 'Your payment of ${payment.formattedAmount} has been processed successfully.',
      data: {'paymentId': payment.id, 'amount': payment.amount},
      priority: NotificationPriority.medium,
    );
  }

  Future<void> notifyDeliveryAssigned({
    required String userId,
    required Delivery delivery,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.deliveryAssigned,
      title: 'Delivery Assigned',
      body: 'Your order has been assigned to ${delivery.courierName}. Estimated delivery: ${_formatTime(delivery.estimatedDeliveryTime)}',
      data: {'deliveryId': delivery.id, 'courierId': delivery.courierId},
      priority: NotificationPriority.medium,
    );
  }

  Future<void> notifyDeliveryPickedUp({
    required String userId,
    required Delivery delivery,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.deliveryPickedUp,
      title: 'Package Picked Up',
      body: '${delivery.courierName} has picked up your package and is on the way!',
      data: {'deliveryId': delivery.id},
      priority: NotificationPriority.medium,
    );
  }

  Future<void> notifyDeliveryInTransit({
    required String userId,
    required Delivery delivery,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.deliveryInTransit,
      title: 'Package In Transit',
      body: 'Your package is on its way. Track live location in the app.',
      data: {'deliveryId': delivery.id},
      priority: NotificationPriority.low,
    );
  }

  Future<void> notifyDeliveryArriving({
    required String userId,
    required Delivery delivery,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.deliveryArriving,
      title: 'Package Arriving Soon',
      body: '${delivery.courierName} is approaching your location. Please be available to receive your package.',
      data: {'deliveryId': delivery.id},
      priority: NotificationPriority.high,
      channels: [NotificationChannel.inApp, NotificationChannel.sms, NotificationChannel.whatsapp],
    );
  }

  Future<void> notifyDeliveryCompleted({
    required String userId,
    required Delivery delivery,
  }) async {
    await createNotification(
      userId: userId,
      type: NotificationType.deliveryCompleted,
      title: 'Package Delivered!',
      body: 'Your package has been delivered successfully. Thank you for using Zed Link!',
      data: {'deliveryId': delivery.id},
      priority: NotificationPriority.high,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Soon';
    
    final difference = dateTime.difference(DateTime.now());
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'soon';
    }
  }
}