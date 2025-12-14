import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transport.dart';

class TransportService {
  final String _flightApiKey = "56f8128dbeab0afeee85241fc57611ba";
  final String _flightBaseUrl = "http://api.aviationstack.com/v1";

  String detectTransportType(String query) {
    final flightPattern = RegExp(r'^[A-Z]{2,3}\d{1,4}$', caseSensitive: false);
    if (flightPattern.hasMatch(query.replaceAll(' ', ''))) {
      return 'flight';
    }
    return 'train';
  }

  Future<List<Transport>> searchTransport(String query) async {
    final type = detectTransportType(query);

    if (type == 'flight') {
      return fetchFlights(query);
    } else {
      return fetchTrains(query);
    }
  }

  Future<List<Transport>> fetchFlights(String flightNumber) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$_flightBaseUrl/flights?access_key=$_flightApiKey&flight_iata=$flightNumber",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          final List results = data['data'];
          return results
              .map((json) => Transport.fromJson(json, 'flight'))
              .toList();
        }
        return [];
      } else {
        throw Exception("Error loading flight data");
      }
    } catch (e) {
      debugPrint("Error fetchFlights: $e");
      return [];
    }
  }

  Future<List<Transport>> fetchTrains(String trainNumber) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return [
        Transport(
          id: trainNumber,
          type: 'train',
          number: trainNumber,
          status: 'scheduled',
          departureAirport: 'Central Station',
          arrivalAirport: 'Main Station',
          departureTime: DateTime.now()
              .add(const Duration(hours: 2))
              .toString(),
          arrivalTime: DateTime.now().add(const Duration(hours: 4)).toString(),
          airline: 'Rail Company',
          departureCity: 'Paris',
          arrivalCity: 'London',
          delay: '0',
        ),
      ];
    } catch (e) {
      debugPrint("Error fetchTrains: $e");
      return [];
    }
  }

  String getRouteUrl(String location, double? lat, double? lon) {
    if (lat != null && lon != null) {
      return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon';
    } else {
      return 'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(location)}';
    }
  }
}
