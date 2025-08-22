import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../models/rating.dart' hide Feedback;
import '../../models/rating.dart' as rating_models;
import 'feedback_screen.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ratings & Feedback'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ratings', icon: Icon(Icons.star)),
            Tab(text: 'Feedback', icon: Icon(Icons.feedback)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FeedbackScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_comment),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatingsTab(),
          _buildFeedbackTab(),
        ],
      ),
    );
  }

  Widget _buildRatingsTab() {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        final ratings = ratingProvider.myRatings;

        if (ratings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_border,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No ratings yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete some orders to start rating',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: ratings.length,
          itemBuilder: (context, index) {
            final rating = ratings[index];
            return _buildRatingCard(rating);
          },
        );
      },
    );
  }

  Widget _buildFeedbackTab() {
    return Consumer<RatingProvider>(
      builder: (context, ratingProvider, child) {
        final feedbacks = ratingProvider.myFeedbacks;

        if (feedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.feedback_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No feedback sent yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share your thoughts with us',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Send Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = feedbacks[index];
            return _buildFeedbackCard(feedback);
          },
        );
      },
    );
  }

  Widget _buildRatingCard(Rating rating) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rating.typeDisplayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating.formattedRating,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Star Display
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            
            if (rating.comment != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(rating.comment!),
              ),
            ],
            
            if (rating.tags != null && rating.tags!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rating.tags!.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue[100],
                )).toList(),
              ),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Rated on ${rating.createdAt.toString().substring(0, 10)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(rating_models.Feedback feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getFeedbackTypeIcon(feedback.type),
                      size: 20,
                      color: _getFeedbackTypeColor(feedback.type),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feedback.typeDisplayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(feedback.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(feedback.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    feedback.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(feedback.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Text(
              feedback.subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              feedback.message,
              style: const TextStyle(color: Colors.grey),
            ),
            
            if (feedback.hasAdminResponse) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Response:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(feedback.adminResponse!),
                    const SizedBox(height: 4),
                    Text(
                      'Responded on ${feedback.adminResponseAt!.toString().substring(0, 10)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Submitted on ${feedback.createdAt.toString().substring(0, 10)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFeedbackTypeIcon(rating_models.FeedbackType type) {
    switch (type) {
      case rating_models.FeedbackType.complaint:
        return Icons.report_problem;
      case rating_models.FeedbackType.suggestion:
        return Icons.lightbulb;
      case rating_models.FeedbackType.compliment:
        return Icons.thumb_up;
      case rating_models.FeedbackType.bugReport:
        return Icons.bug_report;
      case rating_models.FeedbackType.other:
        return Icons.chat;
    }
  }

  Color _getFeedbackTypeColor(rating_models.FeedbackType type) {
    switch (type) {
      case rating_models.FeedbackType.complaint:
        return Colors.red;
      case rating_models.FeedbackType.suggestion:
        return Colors.blue;
      case rating_models.FeedbackType.compliment:
        return Colors.green;
      case rating_models.FeedbackType.bugReport:
        return Colors.orange;
      case rating_models.FeedbackType.other:
        return Colors.purple;
    }
  }

  Color _getStatusColor(rating_models.FeedbackStatus status) {
    switch (status) {
      case rating_models.FeedbackStatus.open:
        return Colors.blue;
      case rating_models.FeedbackStatus.inProgress:
        return Colors.orange;
      case rating_models.FeedbackStatus.resolved:
        return Colors.green;
      case rating_models.FeedbackStatus.closed:
        return Colors.grey;
    }
  }
}