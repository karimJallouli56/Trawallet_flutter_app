import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Trip {
  final String tripId;
  final String userId;
  final String destination;
  final String? coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final DateTime createdAt;
  final String status;

  Trip({
    required this.tripId,
    required this.userId,
    required this.destination,
    this.coverImage,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.createdAt,
    required this.status,
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Trip(
      tripId: doc.id,
      userId: data['userId'] ?? '',
      destination: data['destination'] ?? '',
      coverImage: data['coverImage'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status:
          data['status'] ??
          calculateStatus(
            (data['startDate'] as Timestamp).toDate(),
            (data['endDate'] as Timestamp).toDate(),
          ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'destination': destination,
      'coverImage': coverImage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'status': calculateStatus(startDate, endDate),
    };
  }

  // Static method to calculate status
  static String calculateStatus(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripStart = DateTime(startDate.year, startDate.month, startDate.day);
    final tripEnd = DateTime(endDate.year, endDate.month, endDate.day);

    if (today.isBefore(tripStart)) {
      return 'upcoming';
    } else if (today.isAfter(tripEnd)) {
      return 'completed';
    } else {
      return 'ongoing';
    }
  }

  int get durationDays => endDate.difference(startDate).inDays + 1;

  // Get status display text
  String get statusText {
    switch (status) {
      case 'upcoming':
        final daysUntil = startDate.difference(DateTime.now()).inDays;
        return daysUntil == 0 ? 'Starts today' : 'In $daysUntil days';
      case 'ongoing':
        final daysLeft = endDate.difference(DateTime.now()).inDays;
        return daysLeft == 0 ? 'Last day' : '$daysLeft days left';
      case 'completed':
        return 'Completed';
      default:
        return '';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case 'upcoming':
        return Colors.teal;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get status icon
  IconData get statusIcon {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'ongoing':
        return Icons.flight_takeoff;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
