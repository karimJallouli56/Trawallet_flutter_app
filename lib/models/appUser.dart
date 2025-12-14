import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phone;
  final String country;
  final String gender;
  final int points;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userAvatar;
  final String? bio;
  final List<String> interests;
  final int visitedCountries;
  final String? travelStory;

  AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.gender,
    this.points = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.userAvatar,
    this.bio,
    this.interests = const [],
    this.visitedCountries = 0,
    this.travelStory,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      gender: data['gender'] ?? '',
      points: data['points'] ?? 0,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      userAvatar: data['userAvatar'],
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      visitedCountries: data['visitedCountries'] ?? 0,
      travelStory: data['travelStory'],
    );
  }

  factory AppUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null');
    }
    return AppUser.fromMap(doc.id, data);
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'gender': gender,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'userAvatar': userAvatar,
      'bio': bio,
      'interests': interests,
      'visitedCountries': visitedCountries,
      'travelStory': travelStory,
    };
  }

  AppUser copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phone,
    String? country,
    String? gender,
    int? points,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userAvatar,
    String? bio,
    List<String>? interests,
    int? visitedCountries,
    String? travelStory,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      gender: gender ?? this.gender,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userAvatar: userAvatar ?? this.userAvatar,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      visitedCountries: visitedCountries ?? this.visitedCountries,
      travelStory: travelStory ?? this.travelStory,
    );
  }

  bool get hasTravelStory => travelStory != null && travelStory!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, '
        'points: $points, visitedCountries: $visitedCountries, gender: $gender)';
  }
}
