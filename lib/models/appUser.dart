import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String country;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.createdAt,
  });

  // ---------- Convert Firestore → Model ----------
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      country: data['country'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ---------- Convert Model → Map (Firestore) ----------
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'createdAt': createdAt,
    };
  }
}
