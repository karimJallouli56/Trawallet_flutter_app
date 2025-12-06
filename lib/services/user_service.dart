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
}
