import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/rating.dart';
import '../models/order.dart';
import '../models/delivery.dart';

class RatingProvider with ChangeNotifier {
  List<Rating> _ratings = [];
  List<Feedback> _feedbacks = [];
  bool _isLoading = false;

  List<Rating> get ratings => _ratings;
  List<Feedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  List<Rating> get myRatings => _ratings; // In real app, filter by current user
  List<Feedback> get myFeedbacks => _feedbacks; // In real app, filter by current user

  RatingProvider() {
    _loadRatings();
    _loadFeedbacks();
  }

  Future<void> _loadRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final ratingsJson = prefs.getString('ratings');
    
    if (ratingsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(ratingsJson);
        _ratings = decoded.map((item) => Rating.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading ratings: $e');
      }
    }
  }

  Future<void> _saveRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final ratingsJson = json.encode(_ratings.map((r) => r.toJson()).toList());
    await prefs.setString('ratings', ratingsJson);
  }

  Future<void> _loadFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbacksJson = prefs.getString('feedbacks');
    
    if (feedbacksJson != null) {
      try {
        final List<dynamic> decoded = json.decode(feedbacksJson);
        _feedbacks = decoded.map((item) => Feedback.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading feedbacks: $e');
      }
    }
  }

  Future<void> _saveFeedbacks() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbacksJson = json.encode(_feedbacks.map((f) => f.toJson()).toList());
    await prefs.setString('feedbacks', feedbacksJson);
  }

  // Rating Methods
  Future<Rating> submitRating({
    required String userId,
    required RatingType type,
    required double rating,
    String? orderId,
    String? deliveryId,
    String? supplierId,
    String? courierId,
    String? productId,
    String? comment,
    Map<RatingCategory, double>? categoryRatings,
    List<String>? tags,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRating = Rating(
        id: 'rating_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        orderId: orderId,
        deliveryId: deliveryId,
        supplierId: supplierId,
        courierId: courierId,
        productId: productId,
        type: type,
        rating: rating,
        comment: comment,
        categoryRatings: categoryRatings,
        tags: tags,
        createdAt: DateTime.now(),
        isPublic: true,
        isVerified: false,
      );

      _ratings.add(newRating);
      await _saveRatings();
      notifyListeners();

      return newRating;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRating(String ratingId, {
    double? rating,
    String? comment,
    Map<RatingCategory, double>? categoryRatings,
    List<String>? tags,
  }) async {
    final index = _ratings.indexWhere((r) => r.id == ratingId);
    if (index >= 0) {
      _ratings[index] = _ratings[index].copyWith(
        rating: rating,
        comment: comment,
        categoryRatings: categoryRatings,
        tags: tags,
        updatedAt: DateTime.now(),
      );
      
      await _saveRatings();
      notifyListeners();
    }
  }

  Future<void> deleteRating(String ratingId) async {
    _ratings.removeWhere((r) => r.id == ratingId);
    await _saveRatings();
    notifyListeners();
  }

  // Feedback Methods
  Future<Feedback> submitFeedback({
    required String userId,
    required FeedbackType type,
    required String subject,
    required String message,
    String? orderId,
    String? deliveryId,
    FeedbackPriority priority = FeedbackPriority.medium,
    List<String>? attachments,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final feedback = Feedback(
        id: 'feedback_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        orderId: orderId,
        deliveryId: deliveryId,
        type: type,
        subject: subject,
        message: message,
        priority: priority,
        attachments: attachments,
        createdAt: DateTime.now(),
      );

      _feedbacks.add(feedback);
      await _saveFeedbacks();
      notifyListeners();

      return feedback;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateFeedbackStatus(String feedbackId, FeedbackStatus status, {String? adminResponse}) async {
    final index = _feedbacks.indexWhere((f) => f.id == feedbackId);
    if (index >= 0) {
      _feedbacks[index] = _feedbacks[index].copyWith(
        status: status,
        adminResponse: adminResponse,
        adminResponseAt: adminResponse != null ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      
      await _saveFeedbacks();
      notifyListeners();
    }
  }

  // Query Methods
  List<Rating> getRatingsByType(RatingType type) {
    return _ratings.where((r) => r.type == type).toList();
  }

  List<Rating> getRatingsByOrder(String orderId) {
    return _ratings.where((r) => r.orderId == orderId).toList();
  }

  List<Rating> getRatingsByDelivery(String deliveryId) {
    return _ratings.where((r) => r.deliveryId == deliveryId).toList();
  }

  List<Rating> getRatingsBySupplier(String supplierId) {
    return _ratings.where((r) => r.supplierId == supplierId).toList();
  }

  List<Rating> getRatingsByCourier(String courierId) {
    return _ratings.where((r) => r.courierId == courierId).toList();
  }

  List<Rating> getRatingsByProduct(String productId) {
    return _ratings.where((r) => r.productId == productId).toList();
  }

  Rating? getRatingByOrderAndType(String orderId, RatingType type) {
    try {
      return _ratings.firstWhere(
        (r) => r.orderId == orderId && r.type == type,
      );
    } catch (e) {
      return null;
    }
  }

  bool hasRatedOrder(String orderId, RatingType type) {
    return getRatingByOrderAndType(orderId, type) != null;
  }

  // Statistics Methods
  RatingSummary getRatingSummary({
    String? supplierId,
    String? courierId,
    String? productId,
    RatingType? type,
  }) {
    List<Rating> filteredRatings = _ratings;

    if (supplierId != null) {
      filteredRatings = filteredRatings.where((r) => r.supplierId == supplierId).toList();
    }
    if (courierId != null) {
      filteredRatings = filteredRatings.where((r) => r.courierId == courierId).toList();
    }
    if (productId != null) {
      filteredRatings = filteredRatings.where((r) => r.productId == productId).toList();
    }
    if (type != null) {
      filteredRatings = filteredRatings.where((r) => r.type == type).toList();
    }

    if (filteredRatings.isEmpty) {
      return RatingSummary(
        averageRating: 0.0,
        totalRatings: 0,
        starDistribution: {},
        categoryAverages: {},
        commonTags: [],
      );
    }

    // Calculate average rating
    final totalRating = filteredRatings.fold<double>(0.0, (sum, r) => sum + r.rating);
    final averageRating = totalRating / filteredRatings.length;

    // Calculate star distribution
    final starDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      starDistribution[i] = filteredRatings.where((r) => r.rating.round() == i).length;
    }

    // Calculate category averages
    final categoryAverages = <RatingCategory, double>{};
    for (final category in RatingCategory.values) {
      final categoryRatings = filteredRatings
          .where((r) => r.categoryRatings?.containsKey(category) == true)
          .map((r) => r.categoryRatings![category]!)
          .toList();
      
      if (categoryRatings.isNotEmpty) {
        categoryAverages[category] = categoryRatings.reduce((a, b) => a + b) / categoryRatings.length;
      }
    }

    // Get common tags
    final allTags = <String>[];
    for (final rating in filteredRatings) {
      if (rating.tags != null) {
        allTags.addAll(rating.tags!);
      }
    }
    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }
    final commonTags = tagCounts.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(5)
        .toList();

    return RatingSummary(
      averageRating: averageRating,
      totalRatings: filteredRatings.length,
      starDistribution: starDistribution,
      categoryAverages: categoryAverages,
      commonTags: commonTags,
    );
  }

  List<Feedback> getFeedbacksByStatus(FeedbackStatus status) {
    return _feedbacks.where((f) => f.status == status).toList();
  }

  List<Feedback> getFeedbacksByType(FeedbackType type) {
    return _feedbacks.where((f) => f.type == type).toList();
  }

  int get openFeedbackCount => getFeedbacksByStatus(FeedbackStatus.open).length;
  int get totalFeedbackCount => _feedbacks.length;

  // Convenience methods for common ratings
  Future<Rating> rateOrder({
    required String userId,
    required String orderId,
    required double rating,
    String? comment,
    List<String>? tags,
  }) async {
    return await submitRating(
      userId: userId,
      orderId: orderId,
      type: RatingType.order,
      rating: rating,
      comment: comment,
      tags: tags,
    );
  }

  Future<Rating> rateDelivery({
    required String userId,
    required String deliveryId,
    required String courierId,
    required double rating,
    String? comment,
    Map<RatingCategory, double>? categoryRatings,
    List<String>? tags,
  }) async {
    return await submitRating(
      userId: userId,
      deliveryId: deliveryId,
      courierId: courierId,
      type: RatingType.delivery,
      rating: rating,
      comment: comment,
      categoryRatings: categoryRatings,
      tags: tags,
    );
  }

  Future<Rating> rateSupplier({
    required String userId,
    required String supplierId,
    String? orderId,
    required double rating,
    String? comment,
    Map<RatingCategory, double>? categoryRatings,
    List<String>? tags,
  }) async {
    return await submitRating(
      userId: userId,
      supplierId: supplierId,
      orderId: orderId,
      type: RatingType.supplier,
      rating: rating,
      comment: comment,
      categoryRatings: categoryRatings,
      tags: tags,
    );
  }

  Future<Rating> rateProduct({
    required String userId,
    required String productId,
    String? orderId,
    required double rating,
    String? comment,
    List<String>? tags,
  }) async {
    return await submitRating(
      userId: userId,
      productId: productId,
      orderId: orderId,
      type: RatingType.product,
      rating: rating,
      comment: comment,
      tags: tags,
    );
  }
}