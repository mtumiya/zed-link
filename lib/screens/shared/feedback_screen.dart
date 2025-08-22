import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/rating.dart' hide Feedback;
import '../../models/rating.dart' as rating_models;
import '../../models/order.dart';
import '../../models/delivery.dart';

class FeedbackScreen extends StatefulWidget {
  final Order? order;
  final Delivery? delivery;

  const FeedbackScreen({
    super.key,
    this.order,
    this.delivery,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  rating_models.FeedbackType _selectedType = rating_models.FeedbackType.other;
  rating_models.FeedbackPriority _selectedPriority = rating_models.FeedbackPriority.medium;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Context Info
              if (widget.order != null || widget.delivery != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Related to:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (widget.order != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag, size: 20),
                              const SizedBox(width: 8),
                              Text('Order #${widget.order!.id.substring(widget.order!.id.length - 6).toUpperCase()}'),
                            ],
                          ),
                        ],
                        if (widget.delivery != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.local_shipping, size: 20),
                              const SizedBox(width: 8),
                              Text('Delivery by ${widget.delivery!.courierName}'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Feedback Type
              const Text(
                'Feedback Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<rating_models.FeedbackType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: rating_models.FeedbackType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getFeedbackTypeIcon(type)),
                        const SizedBox(width: 8),
                        Text(_getFeedbackTypeDisplayName(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Priority
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<rating_models.FeedbackPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: rating_models.FeedbackPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(
                          _getPriorityIcon(priority),
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPriorityDisplayName(priority),
                          style: TextStyle(color: _getPriorityColor(priority)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Subject
              const Text(
                'Subject',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Brief description of your feedback',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message
              const Text(
                'Message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Please provide detailed information about your feedback...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  if (value.trim().length < 10) {
                    return 'Message must be at least 10 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Send Feedback',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'What happens next?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Our team will review your feedback within 24-48 hours. You\'ll receive a response via SMS or in-app notification.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  String _getFeedbackTypeDisplayName(rating_models.FeedbackType type) {
    switch (type) {
      case rating_models.FeedbackType.complaint:
        return 'Complaint';
      case rating_models.FeedbackType.suggestion:
        return 'Suggestion';
      case rating_models.FeedbackType.compliment:
        return 'Compliment';
      case rating_models.FeedbackType.bugReport:
        return 'Bug Report';
      case rating_models.FeedbackType.other:
        return 'Other';
    }
  }

  IconData _getPriorityIcon(rating_models.FeedbackPriority priority) {
    switch (priority) {
      case rating_models.FeedbackPriority.low:
        return Icons.keyboard_arrow_down;
      case rating_models.FeedbackPriority.medium:
        return Icons.remove;
      case rating_models.FeedbackPriority.high:
        return Icons.keyboard_arrow_up;
      case rating_models.FeedbackPriority.urgent:
        return Icons.priority_high;
    }
  }

  String _getPriorityDisplayName(rating_models.FeedbackPriority priority) {
    switch (priority) {
      case rating_models.FeedbackPriority.low:
        return 'Low';
      case rating_models.FeedbackPriority.medium:
        return 'Medium';
      case rating_models.FeedbackPriority.high:
        return 'High';
      case rating_models.FeedbackPriority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(rating_models.FeedbackPriority priority) {
    switch (priority) {
      case rating_models.FeedbackPriority.low:
        return Colors.green;
      case rating_models.FeedbackPriority.medium:
        return Colors.orange;
      case rating_models.FeedbackPriority.high:
        return Colors.red;
      case rating_models.FeedbackPriority.urgent:
        return Colors.deepOrange;
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
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

      await ratingProvider.submitFeedback(
        userId: user.id,
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        orderId: widget.order?.id,
        deliveryId: widget.delivery?.id,
        priority: _selectedPriority,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback has been submitted.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
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