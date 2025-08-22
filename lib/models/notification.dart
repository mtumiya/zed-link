enum NotificationType {
  orderConfirmation,
  paymentConfirmation,
  deliveryAssigned,
  deliveryPickedUp,
  deliveryInTransit,
  deliveryArriving,
  deliveryCompleted,
  paymentReminder,
  supplierUpdate,
  systemAlert,
  promotional
}

enum NotificationChannel {
  inApp,
  sms,
  whatsapp,
  email
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent
}

class NotificationPreferences {
  final bool enableInApp;
  final bool enableSMS;
  final bool enableWhatsApp;
  final bool enableEmail;
  final Map<NotificationType, bool> typePreferences;
  final String? whatsappNumber;
  final String? emailAddress;

  NotificationPreferences({
    this.enableInApp = true,
    this.enableSMS = true,
    this.enableWhatsApp = false,
    this.enableEmail = false,
    this.typePreferences = const {},
    this.whatsappNumber,
    this.emailAddress,
  });

  bool isTypeEnabled(NotificationType type) {
    return typePreferences[type] ?? true;
  }

  NotificationPreferences copyWith({
    bool? enableInApp,
    bool? enableSMS,
    bool? enableWhatsApp,
    bool? enableEmail,
    Map<NotificationType, bool>? typePreferences,
    String? whatsappNumber,
    String? emailAddress,
  }) {
    return NotificationPreferences(
      enableInApp: enableInApp ?? this.enableInApp,
      enableSMS: enableSMS ?? this.enableSMS,
      enableWhatsApp: enableWhatsApp ?? this.enableWhatsApp,
      enableEmail: enableEmail ?? this.enableEmail,
      typePreferences: typePreferences ?? this.typePreferences,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      emailAddress: emailAddress ?? this.emailAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableInApp': enableInApp,
      'enableSMS': enableSMS,
      'enableWhatsApp': enableWhatsApp,
      'enableEmail': enableEmail,
      'typePreferences': typePreferences.map((key, value) => MapEntry(key.toString(), value)),
      'whatsappNumber': whatsappNumber,
      'emailAddress': emailAddress,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableInApp: json['enableInApp'] ?? true,
      enableSMS: json['enableSMS'] ?? true,
      enableWhatsApp: json['enableWhatsApp'] ?? false,
      enableEmail: json['enableEmail'] ?? false,
      typePreferences: (json['typePreferences'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          NotificationType.values.firstWhere((e) => e.toString() == key),
          value as bool,
        ),
      ) ?? {},
      whatsappNumber: json['whatsappNumber'],
      emailAddress: json['emailAddress'],
    );
  }
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final NotificationPriority priority;
  final List<NotificationChannel> channels;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isRead;
  final bool isSent;
  final Map<NotificationChannel, bool> deliveryStatus;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.priority = NotificationPriority.medium,
    this.channels = const [NotificationChannel.inApp],
    required this.createdAt,
    this.scheduledAt,
    this.isRead = false,
    this.isSent = false,
    this.deliveryStatus = const {},
  });

  String get typeDisplayName {
    switch (type) {
      case NotificationType.orderConfirmation:
        return 'Order Confirmation';
      case NotificationType.paymentConfirmation:
        return 'Payment Confirmation';
      case NotificationType.deliveryAssigned:
        return 'Delivery Assigned';
      case NotificationType.deliveryPickedUp:
        return 'Package Picked Up';
      case NotificationType.deliveryInTransit:
        return 'Package In Transit';
      case NotificationType.deliveryArriving:
        return 'Package Arriving';
      case NotificationType.deliveryCompleted:
        return 'Package Delivered';
      case NotificationType.paymentReminder:
        return 'Payment Reminder';
      case NotificationType.supplierUpdate:
        return 'Supplier Update';
      case NotificationType.systemAlert:
        return 'System Alert';
      case NotificationType.promotional:
        return 'Promotion';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
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

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
    List<NotificationChannel>? channels,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isRead,
    bool? isSent,
    Map<NotificationChannel, bool>? deliveryStatus,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      channels: channels ?? this.channels,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'body': body,
      'data': data,
      'priority': priority.toString(),
      'channels': channels.map((c) => c.toString()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isRead': isRead,
      'isSent': isSent,
      'deliveryStatus': deliveryStatus.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      title: json['title'],
      body: json['body'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      channels: (json['channels'] as List?)?.map((c) => 
        NotificationChannel.values.firstWhere(
          (e) => e.toString() == c,
          orElse: () => NotificationChannel.inApp,
        )
      ).toList() ?? [NotificationChannel.inApp],
      createdAt: DateTime.parse(json['createdAt']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      isRead: json['isRead'] ?? false,
      isSent: json['isSent'] ?? false,
      deliveryStatus: (json['deliveryStatus'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          NotificationChannel.values.firstWhere((e) => e.toString() == key),
          value as bool,
        ),
      ) ?? {},
    );
  }
}