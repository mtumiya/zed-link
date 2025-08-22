enum RatingType {
  order,
  delivery,
  supplier,
  courier,
  product
}

enum RatingCategory {
  quality,
  delivery,
  communication,
  packaging,
  overall
}

class Rating {
  final String id;
  final String userId;
  final String? orderId;
  final String? deliveryId;
  final String? supplierId;
  final String? courierId;
  final String? productId;
  final RatingType type;
  final double rating; // 1.0 to 5.0
  final String? comment;
  final Map<RatingCategory, double>? categoryRatings;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final bool isVerified;

  Rating({
    required this.id,
    required this.userId,
    this.orderId,
    this.deliveryId,
    this.supplierId,
    this.courierId,
    this.productId,
    required this.type,
    required this.rating,
    this.comment,
    this.categoryRatings,
    this.tags,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = true,
    this.isVerified = false,
  });

  String get formattedRating => rating.toStringAsFixed(1);

  String get typeDisplayName {
    switch (type) {
      case RatingType.order:
        return 'Order Rating';
      case RatingType.delivery:
        return 'Delivery Rating';
      case RatingType.supplier:
        return 'Supplier Rating';
      case RatingType.courier:
        return 'Courier Rating';
      case RatingType.product:
        return 'Product Rating';
    }
  }

  String get starDisplay {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return '★' * fullStars + 
           (hasHalfStar ? '☆' : '') + 
           '☆' * emptyStars;
  }

  Rating copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? deliveryId,
    String? supplierId,
    String? courierId,
    String? productId,
    RatingType? type,
    double? rating,
    String? comment,
    Map<RatingCategory, double>? categoryRatings,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    bool? isVerified,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      deliveryId: deliveryId ?? this.deliveryId,
      supplierId: supplierId ?? this.supplierId,
      courierId: courierId ?? this.courierId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'deliveryId': deliveryId,
      'supplierId': supplierId,
      'courierId': courierId,
      'productId': productId,
      'type': type.toString(),
      'rating': rating,
      'comment': comment,
      'categoryRatings': categoryRatings?.map((key, value) => MapEntry(key.toString(), value)),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPublic': isPublic,
      'isVerified': isVerified,
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['userId'],
      orderId: json['orderId'],
      deliveryId: json['deliveryId'],
      supplierId: json['supplierId'],
      courierId: json['courierId'],
      productId: json['productId'],
      type: RatingType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => RatingType.order,
      ),
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment'],
      categoryRatings: json['categoryRatings'] != null
          ? Map<RatingCategory, double>.fromEntries(
              (json['categoryRatings'] as Map<String, dynamic>).entries.map(
                (e) => MapEntry(
                  RatingCategory.values.firstWhere((cat) => cat.toString() == e.key),
                  e.value.toDouble(),
                ),
              ),
            )
          : null,
      tags: json['tags']?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPublic: json['isPublic'] ?? true,
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> starDistribution; // star count -> number of ratings
  final Map<RatingCategory, double> categoryAverages;
  final List<String> commonTags;

  RatingSummary({
    required this.averageRating,
    required this.totalRatings,
    required this.starDistribution,
    required this.categoryAverages,
    required this.commonTags,
  });

  String get formattedRating => averageRating.toStringAsFixed(1);

  String get starDisplay {
    final fullStars = averageRating.floor();
    final hasHalfStar = averageRating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    return '★' * fullStars + 
           (hasHalfStar ? '☆' : '') + 
           '☆' * emptyStars;
  }

  double getStarPercentage(int stars) {
    if (totalRatings == 0) return 0.0;
    return (starDistribution[stars] ?? 0) / totalRatings;
  }
}

class Feedback {
  final String id;
  final String userId;
  final String? orderId;
  final String? deliveryId;
  final FeedbackType type;
  final String subject;
  final String message;
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? adminResponseAt;

  Feedback({
    required this.id,
    required this.userId,
    this.orderId,
    this.deliveryId,
    required this.type,
    required this.subject,
    required this.message,
    this.priority = FeedbackPriority.medium,
    this.status = FeedbackStatus.open,
    this.attachments,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.adminResponseAt,
  });

  String get statusDisplayName {
    switch (status) {
      case FeedbackStatus.open:
        return 'Open';
      case FeedbackStatus.inProgress:
        return 'In Progress';
      case FeedbackStatus.resolved:
        return 'Resolved';
      case FeedbackStatus.closed:
        return 'Closed';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case FeedbackType.complaint:
        return 'Complaint';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.other:
        return 'Other';
    }
  }

  bool get isResolved => status == FeedbackStatus.resolved || status == FeedbackStatus.closed;
  bool get hasAdminResponse => adminResponse != null;

  Feedback copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? deliveryId,
    FeedbackType? type,
    String? subject,
    String? message,
    FeedbackPriority? priority,
    FeedbackStatus? status,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? adminResponseAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      deliveryId: deliveryId ?? this.deliveryId,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      adminResponseAt: adminResponseAt ?? this.adminResponseAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'deliveryId': deliveryId,
      'type': type.toString(),
      'subject': subject,
      'message': message,
      'priority': priority.toString(),
      'status': status.toString(),
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
      'adminResponseAt': adminResponseAt?.toIso8601String(),
    };
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['userId'],
      orderId: json['orderId'],
      deliveryId: json['deliveryId'],
      type: FeedbackType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => FeedbackType.other,
      ),
      subject: json['subject'],
      message: json['message'],
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => FeedbackStatus.open,
      ),
      attachments: json['attachments']?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      adminResponse: json['adminResponse'],
      adminResponseAt: json['adminResponseAt'] != null ? DateTime.parse(json['adminResponseAt']) : null,
    );
  }
}

enum FeedbackType {
  complaint,
  suggestion,
  compliment,
  bugReport,
  other
}

enum FeedbackPriority {
  low,
  medium,
  high,
  urgent
}

enum FeedbackStatus {
  open,
  inProgress,
  resolved,
  closed
}