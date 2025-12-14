import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trawallet_final_version/models/post.dart';

class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      commentId: doc.id,
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Future<String> addComment({
    required String postId,
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('comments').doc();

      await docRef.set({
        'postId': postId,
        'userId': userId,
        'username': username,
        'userAvatar': userAvatar,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await Post.incrementCommentCount(postId);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<void> deleteComment(String commentId, String postId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('comments').doc(commentId).delete();
      await Post.decrementCommentCount(postId);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  static Stream<List<Comment>> getComments(String postId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }
}
