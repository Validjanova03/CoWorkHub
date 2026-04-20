import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../models/feedback.dart';

class FeedbackScreen extends StatefulWidget {
  final int userId;
  final int? preSelectedResourceId;

  const FeedbackScreen({
    super.key, //super.key instead of Key? key
    required this.userId,
    this.preSelectedResourceId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final DBHelper _db = DBHelper();
  List<Map<String, dynamic>> _resources = [];
  int? _selectedResourceId;
  double _rating = 3;
  final TextEditingController _commentController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() => _loading = true);
    final allResources = await _db.getAllResources();
    if (!mounted) return; //Check before using setState
    setState(() {
      _resources = allResources;
      if (widget.preSelectedResourceId != null &&
          _resources.any((r) => r['resource_id'] == widget.preSelectedResourceId)) {
        _selectedResourceId = widget.preSelectedResourceId;
      } else if (_resources.isNotEmpty) {
        _selectedResourceId = _resources.first['resource_id'];
      }
      _loading = false;
    });
  }

  Future<void> _submitFeedback() async {
    if (_selectedResourceId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workspace or amenity')),
      );
      return;
    }
    final feedback = FeedbackModel(
      userId: widget.userId,
      resourceId: _selectedResourceId!,
      rating: _rating,
      message: _commentController.text.trim(),
      submittedAt: DateTime.now().toIso8601String(),
    );
    await _db.insertFeedback(feedback.toMap());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_loading)
              const CircularProgressIndicator()
            else
              DropdownButtonFormField<int>(
                //use initialValue instead of deprecated 'value'
                initialValue: _selectedResourceId,
                items: _resources.map<DropdownMenuItem<int>>((r) {
                  return DropdownMenuItem<int>(
                    value: r['resource_id'] as int,
                    child: Text('${r['name']} (${r['resource_type']})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedResourceId = val),
                decoration: const InputDecoration(labelText: 'Select workspace or amenity'),
              ),
            const SizedBox(height: 20),
            const Text('Rating:'),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (val) => setState(() => _rating = val),
            ),
            Text('${_rating.toStringAsFixed(1)} stars'),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 3,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}