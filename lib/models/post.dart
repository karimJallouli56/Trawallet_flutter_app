import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final List<String> images;
  final String? location;
  final String category; // 'photo', 'tip', 'review'
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLikedByCurrentUser;
  final List<String> likedBy;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    required this.images,
    this.location,
    required this.category,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
    this.likedBy = const [],
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      postId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      location: data['location'],
      category: data['category'] ?? 'photo',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  factory Post.fromFirestoreWithUser(
    DocumentSnapshot doc,
    String currentUserId,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);

    return Post(
      postId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      location: data['location'],
      category: data['category'] ?? 'photo',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likedBy: likedBy,
      isLikedByCurrentUser: likedBy.contains(currentUserId),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'location': location,
      'category': category,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
    };
  }

  Post copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    List<String>? images,
    String? location,
    String? category,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    bool? isLikedByCurrentUser,
    List<String>? likedBy,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      location: location ?? this.location,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Anonymous',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      location: json['location'],
      category: json['category'] ?? 'photo',
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'location': location,
      'category': category,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
    };
  }

  static Future<String> addPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String content,
    required List<String> images,
    String? location,
    required String category,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('posts').doc();

      final postData = {
        'postId': docRef.id,
        'userId': userId,
        'username': username,
        'userAvatar': userAvatar,
        'content': content,
        'images': images,
        'location': location,
        'category': category,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'likedBy': [],
      };

      await docRef.set(postData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add post: $e');
    }
  }

  static Future<Post?> getPost(String postId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('posts').doc(postId).get();

      if (doc.exists) {
        return Post.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  static Stream<List<Post>> getAllPostsWithUser(String currentUserId) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => Post.fromFirestoreWithUser(doc, currentUserId))
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  static Stream<List<Post>> getUserPosts(String userId) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
          );
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  static Stream<List<Post>> getPostsByCategory(String category) {
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('posts')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
          );
    } catch (e) {
      throw Exception('Failed to get posts by category: $e');
    }
  }

  static Future<void> updatePost(
    String postId, {
    String? content,
    List<String>? images,
    String? location,
    String? category,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final updateData = <String, dynamic>{};

      if (content != null) updateData['content'] = content;
      if (images != null) updateData['images'] = images;
      if (location != null) updateData['location'] = location;
      if (category != null) updateData['category'] = category;

      if (updateData.isNotEmpty) {
        await firestore.collection('posts').doc(postId).update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  static Future<void> toggleLike(String postId, String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final postRef = firestore.collection('posts').doc(postId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception('Post does not exist');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        final likesCount = data['likesCount'] ?? 0;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount - 1,
          });
        } else {
          // Like
          likedBy.add(userId);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount + 1,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  static Future<void> incrementCommentCount(String postId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment comment count: $e');
    }
  }

  static Future<void> decrementCommentCount(String postId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to decrement comment count: $e');
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // INSTANCE METHODS
  // Save current instance to Firestore
  Future<void> save() async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('posts').doc(postId).set(toFirestore());
    } catch (e) {
      throw Exception('Failed to save post: $e');
    }
  }

  // Delete current instance from Firestore
  Future<void> delete() async {
    await Post.deletePost(postId);
  }

  // Update current instance in Firestore
  Future<void> update({
    String? content,
    List<String>? images,
    String? location,
    String? category,
  }) async {
    await Post.updatePost(
      postId,
      content: content,
      images: images,
      location: location,
      category: category,
    );
  }
}
