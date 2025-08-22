enum DeliveryStatus {
  pending,
  assigned,
  pickupReady,
  pickedUp,
  inTransit,
  nearDelivery,
  delivered,
  failed,
  cancelled
}

class DeliveryLocation {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DeliveryUpdate {
  final String id;
  final DeliveryStatus status;
  final String message;
  final DateTime timestamp;
  final DeliveryLocation? location;
  final String? imageUrl; // Proof of delivery photo

  DeliveryUpdate({
    required this.id,
    required this.status,
    required this.message,
    required this.timestamp,
    this.location,
    this.imageUrl,
  });

  String get statusName {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending Assignment';
      case DeliveryStatus.assigned:
        return 'Assigned to Courier';
      case DeliveryStatus.pickupReady:
        return 'Ready for Pickup';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.nearDelivery:
        return 'Near Delivery Location';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Delivery Failed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toString(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'location': location?.toJson(),
      'imageUrl': imageUrl,
    };
  }

  factory DeliveryUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdate(
      id: json['id'],
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'] != null 
          ? DeliveryLocation.fromJson(json['location']) 
          : null,
      imageUrl: json['imageUrl'],
    );
  }
}

class Delivery {
  final String id;
  final String orderId;
  final String courierId;
  final String courierName;
  final String courierPhone;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final DeliveryLocation? pickupLocation;
  final DeliveryLocation? deliveryLocation;
  final DeliveryStatus status;
  final List<DeliveryUpdate> updates;
  final double? estimatedDistance; // in kilometers
  final double? deliveryFee;
  final DateTime createdAt;
  final DateTime? estimatedPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDeliveryTime;
  final String? specialInstructions;
  final String? proofOfDeliveryUrl;

  Delivery({
    required this.id,
    required this.orderId,
    required this.courierId,
    required this.courierName,
    required this.courierPhone,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.pickupLocation,
    this.deliveryLocation,
    this.status = DeliveryStatus.pending,
    this.updates = const [],
    this.estimatedDistance,
    this.deliveryFee,
    required this.createdAt,
    this.estimatedPickupTime,
    this.estimatedDeliveryTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
    this.specialInstructions,
    this.proofOfDeliveryUrl,
  });

  String get statusName {
    return status.toString().split('.').last;
  }

  String get formattedDeliveryFee => 
      deliveryFee != null ? 'K${deliveryFee!.toStringAsFixed(2)}' : 'Free';

  bool get isCompleted => status == DeliveryStatus.delivered;
  bool get isActive => !isCompleted && status != DeliveryStatus.cancelled && status != DeliveryStatus.failed;
  bool get canTrack => status != DeliveryStatus.pending;

  Duration? get estimatedDuration {
    if (estimatedPickupTime != null && estimatedDeliveryTime != null) {
      return estimatedDeliveryTime!.difference(estimatedPickupTime!);
    }
    return null;
  }

  String get estimatedDurationText {
    final duration = estimatedDuration;
    if (duration == null) return 'Unknown';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  DeliveryUpdate get latestUpdate {
    if (updates.isEmpty) {
      return DeliveryUpdate(
        id: '${id}_init',
        status: status,
        message: 'Delivery created',
        timestamp: createdAt,
      );
    }
    return updates.last;
  }

  Delivery copyWith({
    String? id,
    String? orderId,
    String? courierId,
    String? courierName,
    String? courierPhone,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? pickupAddress,
    String? deliveryAddress,
    DeliveryLocation? pickupLocation,
    DeliveryLocation? deliveryLocation,
    DeliveryStatus? status,
    List<DeliveryUpdate>? updates,
    double? estimatedDistance,
    double? deliveryFee,
    DateTime? createdAt,
    DateTime? estimatedPickupTime,
    DateTime? estimatedDeliveryTime,
    DateTime? actualPickupTime,
    DateTime? actualDeliveryTime,
    String? specialInstructions,
    String? proofOfDeliveryUrl,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      status: status ?? this.status,
      updates: updates ?? this.updates,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      estimatedPickupTime: estimatedPickupTime ?? this.estimatedPickupTime,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualPickupTime: actualPickupTime ?? this.actualPickupTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'courierId': courierId,
      'courierName': courierName,
      'courierPhone': courierPhone,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'pickupLocation': pickupLocation?.toJson(),
      'deliveryLocation': deliveryLocation?.toJson(),
      'status': status.toString(),
      'updates': updates.map((u) => u.toJson()).toList(),
      'estimatedDistance': estimatedDistance,
      'deliveryFee': deliveryFee,
      'createdAt': createdAt.toIso8601String(),
      'estimatedPickupTime': estimatedPickupTime?.toIso8601String(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'actualPickupTime': actualPickupTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'proofOfDeliveryUrl': proofOfDeliveryUrl,
    };
  }

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'],
      orderId: json['orderId'],
      courierId: json['courierId'],
      courierName: json['courierName'],
      courierPhone: json['courierPhone'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientPhone: json['clientPhone'],
      pickupAddress: json['pickupAddress'],
      deliveryAddress: json['deliveryAddress'],
      pickupLocation: json['pickupLocation'] != null 
          ? DeliveryLocation.fromJson(json['pickupLocation']) 
          : null,
      deliveryLocation: json['deliveryLocation'] != null 
          ? DeliveryLocation.fromJson(json['deliveryLocation']) 
          : null,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      updates: (json['updates'] as List?)
          ?.map((u) => DeliveryUpdate.fromJson(u))
          .toList() ?? [],
      estimatedDistance: json['estimatedDistance']?.toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      estimatedPickupTime: json['estimatedPickupTime'] != null 
          ? DateTime.parse(json['estimatedPickupTime']) 
          : null,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null 
          ? DateTime.parse(json['estimatedDeliveryTime']) 
          : null,
      actualPickupTime: json['actualPickupTime'] != null 
          ? DateTime.parse(json['actualPickupTime']) 
          : null,
      actualDeliveryTime: json['actualDeliveryTime'] != null 
          ? DateTime.parse(json['actualDeliveryTime']) 
          : null,
      specialInstructions: json['specialInstructions'],
      proofOfDeliveryUrl: json['proofOfDeliveryUrl'],
    );
  }
}