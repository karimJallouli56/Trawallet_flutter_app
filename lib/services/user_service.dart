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

  Future<void> updateUserField(String uid, String field, dynamic value) async {
    await _firestore.collection('users').doc(uid).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('User field "$field" updated successfully');
  }

  Future<void> deleteUser(String uid) async {
    try {
      WriteBatch batch = _firestore.batch();
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      batch.delete(userRef);
      final tripsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trips')
          .get();

      for (var doc in tripsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final bookingsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bookings')
          .get();

      for (var doc in bookingsSnapshot.docs) {
        batch.delete(doc.reference);
      }

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

      await batch.commit();

      print('User and all associated data deleted successfully for uid: $uid');
    } catch (e) {
      print('Error deleting user: $e');
      throw 'Failed to delete user data: $e';
    }
  }

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
}
