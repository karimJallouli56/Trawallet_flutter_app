import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trawallet_final_version/models/activity.dart';
import 'package:trawallet_final_version/models/trip.dart';

class TripService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createTrip(Trip trip) async {
    final docRef = await _firestore.collection('trips').add(trip.toFirestore());
    return docRef.id;
  }

  static Future<void> updateTrip(Trip trip) async {
    await _firestore
        .collection('trips')
        .doc(trip.tripId)
        .update(trip.toFirestore());
  }

  static Stream<List<Trip>> getUserTrips(String userId) {
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs
              .map((doc) => Trip.fromFirestore(doc))
              .toList();
          trips.sort((a, b) => b.startDate.compareTo(a.startDate));
          return trips;
        });
  }

  static Future<void> deleteTrip(String tripId) async {
    final activities = await _firestore
        .collection('activities')
        .where('tripId', isEqualTo: tripId)
        .get();

    for (var doc in activities.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('trips').doc(tripId).delete();
  }

  static Future<void> updateTripStatus(
    String tripId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final newStatus = Trip.calculateStatus(startDate, endDate);
    await _firestore.collection('trips').doc(tripId).update({
      'status': newStatus,
    });
  }

  static Future<void> updateAllUserTripStatuses(String userId) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();
      final newStatus = Trip.calculateStatus(startDate, endDate);
      if (data['status'] != newStatus) {
        batch.update(doc.reference, {'status': newStatus});
      }
    }
    await batch.commit();
  }

  static Future<List<Activity>> getCompletedActivities(String userId) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .get();

    final activities = snapshot.docs
        .map((doc) => Activity.fromFirestore(doc))
        .toList();
    activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return activities;
  }

  static Future<Map<String, int>> getUserTripStats(String userId) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();

    int completed = 0;
    int ongoing = 0;
    int upcoming = 0;
    int totalDays = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();
      final days = endDate.difference(startDate).inDays + 1;

      switch (status) {
        case 'completed':
          completed++;
          totalDays += days;
          break;
        case 'ongoing':
          ongoing++;
          break;
        case 'upcoming':
          upcoming++;
          break;
      }
    }

    return {
      'completed': completed,
      'ongoing': ongoing,
      'upcoming': upcoming,
      'totalDays': totalDays,
      'total': completed + ongoing + upcoming,
    };
  }

  static Future<List<Trip>> getCompletedTrips(String userId) async {
    final snapshot = await _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();

    final trips = snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
    trips.sort((a, b) => b.endDate.compareTo(a.endDate));
    return trips;
  }
}

class ActivityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createActivity(Activity activity) async {
    final docRef = await _firestore
        .collection('activities')
        .add(activity.toFirestore());
    return docRef.id;
  }

  static Stream<List<Activity>> getTripActivities(String tripId) {
    return _firestore
        .collection('activities')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
          final activities = snapshot.docs
              .map((doc) => Activity.fromFirestore(doc))
              .toList();
          activities.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return activities;
        });
  }

  static Future<void> toggleActivityComplete(
    String activityId,
    bool isCompleted,
  ) async {
    await _firestore.collection('activities').doc(activityId).update({
      'isCompleted': isCompleted,
    });

    if (isCompleted) {
      final activity = await _firestore
          .collection('activities')
          .doc(activityId)
          .get();
      final points = (activity.data()?['rewardPoints'] ?? 10) as int;
      await _awardPoints(activity.data()?['userId'], points);
    }
  }

  static Future<void> _awardPoints(String userId, int points) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({'rewardPoints': FieldValue.increment(points)});
  }

  static Future<void> deleteActivity(String activityId) async {
    await _firestore.collection('activities').doc(activityId).delete();
  }

  static Future<void> updateActivity(
    String activityId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('activities').doc(activityId).update(data);
  }
}
