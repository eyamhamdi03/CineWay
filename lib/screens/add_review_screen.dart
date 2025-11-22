import 'package:flutter/material.dart';

import '../core/colors.dart';

class NewReviewData {
  final double rating;
  final String comment;

  NewReviewData({required this.rating, required this.comment});
}

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key});

  @override
  State<AddReviewScreen> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewScreen> {
  double _rating = 3;
  final TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),

      title: const Text(
        "Add Review",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),

      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Simple stars selector
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 28,
                  onPressed: () {
                    setState(() {
                      _rating = starIndex.toDouble();
                    });
                  },
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: AppColors.cerulean,
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            const Text(
              "Your comment",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),

            TextFormField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write something about the movie...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF262626),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Comment is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cerulean,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                NewReviewData(
                  rating: _rating,
                  comment: _commentController.text.trim(),
                ),
              );
            }
          },
          child: const Text( "Submit",style: TextStyle(color:Colors.white)),
        ),
      ],
    );
  }
}
