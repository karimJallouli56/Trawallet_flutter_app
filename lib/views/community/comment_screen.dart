import 'package:flutter/material.dart';
import 'package:trawallet_final_version/models/post.dart';

class CommentsScreen extends StatelessWidget {
  final Post post;

  const CommentsScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Center(child: Text('Comments for ${post.username}\'s post')),
    );
  }
}
