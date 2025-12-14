import 'package:flutter/material.dart';

class AddPostCard extends StatelessWidget {
  final String userAvatar;
  final VoidCallback onTap;

  const AddPostCard({super.key, required this.userAvatar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            spreadRadius: -2,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: NetworkImage(userAvatar)),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "What's on your mind?",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.photo_library, color: Colors.teal),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
