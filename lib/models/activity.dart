import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String activityId;
  final String tripId;
  final String userId;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String category; // sightseeing, food, transport, accommodation, other
  final bool isCompleted;
  final String? notes;
  final int rewardPoints;

  Activity({
    required this.activityId,
    required this.tripId,
    required this.userId,
    required this.title,
    this.description,
    required this.dateTime,
    this.location,
    this.latitude,
    this.longitude,
    required this.category,
    this.isCompleted = false,
    this.notes,
    this.rewardPoints = 10,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      activityId: doc.id,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      category: data['category'] ?? 'other',
      isCompleted: data['isCompleted'] ?? false,
      notes: data['notes'],
      rewardPoints: data['rewardPoints'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'isCompleted': isCompleted,
      'notes': notes,
      'rewardPoints': rewardPoints,
    };
  }

  Activity copyWith({
    String? activityId,
    String? tripId,
    String? userId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    double? latitude,
    double? longitude,
    String? category,
    bool? isCompleted,
    String? notes,
    int? rewardPoints,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      rewardPoints: rewardPoints ?? this.rewardPoints,
    );
  }
}
