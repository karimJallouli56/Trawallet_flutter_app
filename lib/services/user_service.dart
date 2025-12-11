import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trawallet_final_version/models/appUser.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(uid).update(data);
    print('User profile updated successfully for uid: $uid');
  }

  /// Updates specific user field
  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _firestore.collection('users').doc(uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('User field "$field" updated successfully');
  }

  /// Deletes user document and all associated data
  Future<void> deleteUser(String uid) async {
    try {
      // Use a batch to delete multiple documents atomically
      WriteBatch batch = _firestore.batch();

      // Delete main user document
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      batch.delete(userRef);

      // Delete user's subcollections if any
      // Example: Delete user's trips
      final tripsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .get();

      for (var doc in tripsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Example: Delete user's bookings
      final bookingsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .get();

      for (var doc in bookingsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's data from other collections where they might be referenced
      // Example: Delete user's posts/reviews/comments
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in reviewsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit the batch
      await batch.commit();

      print('User and all associated data deleted successfully for uid: $uid');
    } catch (e) {
      print('Error deleting user: $e');
      throw 'Failed to delete user data: $e';
    }
  }

  /// Alternative: Soft delete (mark as deleted instead of actually deleting)
  Future<void> softDeleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User soft deleted successfully for uid: $uid');
    } catch (e) {
      print('Error soft deleting user: $e');
      throw 'Failed to soft delete user: $e';
    }
  }

  /// Helper method to delete a collection in batches (for large collections)
  Future<void> _deleteCollection(
    CollectionReference collection, {
    int batchSize = 500,
  }) async {
    QuerySnapshot snapshot = await collection.limit(batchSize).get();

    while (snapshot.docs.isNotEmpty) {
      WriteBatch batch = _firestore.batch();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Get next batch
      snapshot = await collection.limit(batchSize).get();
    }
  }
}
