import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/rating_provider.dart';
import '../../models/rating.dart' as rating_models;

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Support'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'In Progress'),
            Tab(text: 'Resolved'),
            Tab(text: 'All Feedback'),
          ],
        ),
      ),
      body: Consumer2<AdminProvider, RatingProvider>(
        builder: (context, adminProvider, ratingProvider, child) {
          final stats = adminProvider.dashboardStats;
          final feedbacks = ratingProvider.feedbacks;
          
          return Column(
            children: [
              // Feedback Statistics
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total Feedback', '${stats.totalFeedbacks}', Icons.feedback, Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Open Issues', '${stats.openFeedbacks}', Icons.priority_high, Colors.red),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard('Resolved', '${stats.totalFeedbacks - stats.openFeedbacks}', Icons.check_circle, Colors.green),
                    ),
                  ],
                ),
              ),

              // Feedback List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFeedbackList(ratingProvider.getFeedbacksByStatus(rating_models.FeedbackStatus.open)),
                    _buildFeedbackList(ratingProvider.getFeedbacksByStatus(rating_models.FeedbackStatus.inProgress)),
                    _buildFeedbackList(ratingProvider.getFeedbacksByStatus(rating_models.FeedbackStatus.resolved)),
                    _buildFeedbackList(feedbacks),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackList(List<rating_models.Feedback> feedbacks) {
    if (feedbacks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No feedback found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
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
  }

  Widget _buildFeedbackCard(rating_models.Feedback feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getFeedbackTypeColor(feedback.type),
          child: Icon(
            _getFeedbackTypeIcon(feedback.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(feedback.subject)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(feedback.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback.statusDisplayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(feedback.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(feedback.typeDisplayName),
            Text(
              'Submitted: ${feedback.createdAt.toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(feedback.message),
                ),
                
                if (feedback.hasAdminResponse) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Response:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(feedback.adminResponse!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Responded: ${feedback.adminResponseAt!.toString().substring(0, 16)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _responseController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Type your response...',
                      border: OutlineInputBorder(),
                      labelText: 'Admin Response',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _respondToFeedback(feedback, rating_models.FeedbackStatus.inProgress),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('In Progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _respondToFeedback(feedback, rating_models.FeedbackStatus.resolved),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _respondToFeedback(rating_models.Feedback feedback, rating_models.FeedbackStatus status) async {
    if (_responseController.text.trim().isEmpty && status == rating_models.FeedbackStatus.resolved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a response before resolving'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
      
      if (_responseController.text.trim().isNotEmpty) {
        await ratingProvider.updateFeedbackStatus(
          feedback.id,
          status,
          adminResponse: _responseController.text.trim(),
        );
      } else {
        await ratingProvider.updateFeedbackStatus(feedback.id, status);
      }

      _responseController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback ${status.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        return Colors.red;
      case rating_models.FeedbackStatus.inProgress:
        return Colors.orange;
      case rating_models.FeedbackStatus.resolved:
        return Colors.green;
      case rating_models.FeedbackStatus.closed:
        return Colors.grey;
    }
  }
}