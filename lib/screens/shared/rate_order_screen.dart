import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/delivery.dart';
import '../../models/rating.dart';

class RateOrderScreen extends StatefulWidget {
  final Order order;
  final Delivery? delivery;

  const RateOrderScreen({
    super.key,
    required this.order,
    this.delivery,
  });

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Order Rating
  double _orderRating = 0.0;
  final _orderCommentController = TextEditingController();
  final _orderTagController = TextEditingController();
  List<String> _orderTags = [];

  // Delivery Rating  
  double _deliveryRating = 0.0;
  final _deliveryCommentController = TextEditingController();
  final _deliveryTagController = TextEditingController();
  List<String> _deliveryTags = [];
  final Map<RatingCategory, double> _categoryRatings = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.delivery != null ? 2 : 1,
      vsync: this,
    );
    
    // Initialize category ratings
    for (final category in RatingCategory.values) {
      _categoryRatings[category] = 0.0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _orderCommentController.dispose();
    _orderTagController.dispose();
    _deliveryCommentController.dispose();
    _deliveryTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: widget.delivery != null
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Order', icon: Icon(Icons.shopping_bag)),
                  Tab(text: 'Delivery', icon: Icon(Icons.local_shipping)),
                ],
              )
            : null,
      ),
      body: widget.delivery != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildOrderRatingTab(),
                _buildDeliveryRatingTab(),
              ],
            )
          : _buildOrderRatingTab(),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRatings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Submit Ratings',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildOrderRatingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Order ID: #${widget.order.id.substring(widget.order.id.length - 6).toUpperCase()}'),
                  Text('Total: ${widget.order.formattedTotal}'),
                  Text('Items: ${widget.order.items.length}'),
                  if (widget.order.deliveryAddress != null)
                    Text('Address: ${widget.order.deliveryAddress}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overall Rating
          const Text(
            'How would you rate your overall order experience?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildStarRating(
            rating: _orderRating,
            onRatingChanged: (rating) {
              setState(() {
                _orderRating = rating;
              });
            },
          ),
          
          const SizedBox(height: 24),

          // Comment Section
          const Text(
            'Tell us more about your experience (optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _orderCommentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share your feedback about the order quality, packaging, etc.',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 24),

          // Tags Section
          const Text(
            'Quick Tags',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...['Fresh', 'Good Quality', 'Fast Service', 'Great Packaging', 'Value for Money', 'Will Order Again']
                  .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: _orderTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _orderTags.add(tag);
                            } else {
                              _orderTags.remove(tag);
                            }
                          });
                        },
                      )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Custom Tag Input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _orderTagController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom tag',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final tag = _orderTagController.text.trim();
                  if (tag.isNotEmpty && !_orderTags.contains(tag)) {
                    setState(() {
                      _orderTags.add(tag);
                      _orderTagController.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          
          if (_orderTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _orderTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _orderTags.remove(tag);
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryRatingTab() {
    if (widget.delivery == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Courier: ${widget.delivery!.courierName}'),
                  Text('Status: ${widget.delivery!.status.toString().split('.').last}'),
                  if (widget.delivery!.actualDeliveryTime != null)
                    Text('Delivered: ${widget.delivery!.actualDeliveryTime.toString().substring(0, 16)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overall Delivery Rating
          const Text(
            'How would you rate the delivery service?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildStarRating(
            rating: _deliveryRating,
            onRatingChanged: (rating) {
              setState(() {
                _deliveryRating = rating;
              });
            },
          ),
          
          const SizedBox(height: 24),

          // Category Ratings
          const Text(
            'Rate Different Aspects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          ..._buildCategoryRatings(),

          const SizedBox(height: 24),

          // Comment Section
          const Text(
            'Tell us more about the delivery (optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deliveryCommentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share your feedback about the delivery experience...',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 24),

          // Delivery Tags
          const Text(
            'Quick Tags',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...['On Time', 'Friendly Courier', 'Careful Handling', 'Professional', 'Good Communication', 'Fast Delivery']
                  .map((tag) => FilterChip(
                        label: Text(tag),
                        selected: _deliveryTags.contains(tag),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _deliveryTags.add(tag);
                            } else {
                              _deliveryTags.remove(tag);
                            }
                          });
                        },
                      )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Custom Tag Input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _deliveryTagController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom tag',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final tag = _deliveryTagController.text.trim();
                  if (tag.isNotEmpty && !_deliveryTags.contains(tag)) {
                    setState(() {
                      _deliveryTags.add(tag);
                      _deliveryTagController.clear();
                    });
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          
          if (_deliveryTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _deliveryTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _deliveryTags.remove(tag);
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating({
    required double rating,
    required ValueChanged<double> onRatingChanged,
    double size = 40.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () => onRatingChanged(starIndex.toDouble()),
          child: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: starIndex <= rating ? Colors.amber : Colors.grey,
            size: size,
          ),
        );
      }),
    );
  }

  List<Widget> _buildCategoryRatings() {
    final categories = [
      (RatingCategory.delivery, 'Delivery Speed', Icons.timer),
      (RatingCategory.communication, 'Communication', Icons.chat),
      (RatingCategory.packaging, 'Package Condition', Icons.inventory),
      (RatingCategory.quality, 'Service Quality', Icons.star),
    ];

    return categories.map((categoryData) {
      final category = categoryData.$1;
      final title = categoryData.$2;
      final icon = categoryData.$3;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStarRating(
                  rating: _categoryRatings[category]!,
                  onRatingChanged: (rating) {
                    setState(() {
                      _categoryRatings[category] = rating;
                    });
                  },
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _submitRatings() async {
    if (_orderRating == 0.0 && (widget.delivery == null || _deliveryRating == 0.0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('User not found');
      }

      // Submit order rating
      if (_orderRating > 0.0) {
        await ratingProvider.rateOrder(
          userId: user.id,
          orderId: widget.order.id,
          rating: _orderRating,
          comment: _orderCommentController.text.trim().isEmpty
              ? null
              : _orderCommentController.text.trim(),
          tags: _orderTags.isEmpty ? null : _orderTags,
        );
      }

      // Submit delivery rating
      if (widget.delivery != null && _deliveryRating > 0.0) {
        await ratingProvider.rateDelivery(
          userId: user.id,
          deliveryId: widget.delivery!.id,
          courierId: widget.delivery!.courierId,
          rating: _deliveryRating,
          comment: _deliveryCommentController.text.trim().isEmpty
              ? null
              : _deliveryCommentController.text.trim(),
          categoryRatings: _categoryRatings.entries
              .where((entry) => entry.value > 0.0)
              .isEmpty
              ? null
              : Map.fromEntries(_categoryRatings.entries
                  .where((entry) => entry.value > 0.0)),
          tags: _deliveryTags.isEmpty ? null : _deliveryTags,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit ratings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}