import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:trawallet_final_version/models/emergency.dart';
import 'package:trawallet_final_version/models/travelerLocation.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyService {
  static const String _apiBaseUrl =
      'https://emergencynumberapi.com/api/country';

  Future<bool> checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<TravelerLocation?> getTravelerLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Could not get location details');
      }

      final place = placemarks.first;

      return TravelerLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: '${place.street ?? ''}, ${place.subLocality ?? ''}',
        city: place.locality ?? place.subAdministrativeArea ?? 'Unknown',
        country: place.country ?? 'Unknown',
        countryCode: place.isoCountryCode?.toUpperCase() ?? 'XX',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting traveler location: $e');
      return null;
    }
  }

  Future<Emergency?> fetchEmergencyNumbers(String countryCode) async {
    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/$countryCode'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['error'] != null && data['error'].toString().isNotEmpty) {
          throw Exception(data['error']);
        }

        return Emergency.fromJson(data);
      } else {
        throw Exception('Failed to load emergency numbers');
      }
    } catch (e) {
      debugPrint('Error fetching emergency numbers: $e');
      return null;
    }
  }

  Future<Emergency?> getEmergencys() async {
    final location = await getTravelerLocation();
    if (location == null) return null;

    return await fetchEmergencyNumbers(location.countryCode);
  }

  Future<void> makeEmergencyCall(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Cannot make phone call');
      }
    } catch (e) {
      debugPrint('Error making emergency call: $e');
      rethrow;
    }
  }

  String getCountryFlag(String countryCode) {
    if (countryCode.length != 2) return 'https://flagcdn.com/un.svg';
    return 'https://flagcdn.com/${countryCode.toLowerCase()}.svg';
  }
}
