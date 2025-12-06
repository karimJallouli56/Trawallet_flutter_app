import 'dart:ui';

import 'package:flutter/material.dart';

class Transport {
  final String id;
  final String type; // 'flight' or 'train'
  final String number;
  final String status;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String? gate;
  final String? terminal;
  final String? delay;
  final String airline;
  final String departureCity;
  final String arrivalCity;

  Transport({
    required this.id,
    required this.type,
    required this.number,
    required this.status,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    this.gate,
    this.terminal,
    this.delay,
    required this.airline,
    required this.departureCity,
    required this.arrivalCity,
  });

  factory Transport.fromJson(Map<String, dynamic> json, String transportType) {
    if (transportType == 'flight') {
      return Transport(
        id: json['flight']?['iata'] ?? json['flight']?['icao'] ?? '',
        type: 'flight',
        number:
            json['flight']?['iata'] ??
            json['flight']?['icao'] ??
            json['flight']?['number'] ??
            '',
        status: json['flight_status'] ?? 'unknown',
        departureAirport: json['departure']?['iata'] ?? '',
        arrivalAirport: json['arrival']?['iata'] ?? '',
        departureTime: json['departure']?['scheduled'] ?? '',
        arrivalTime: json['arrival']?['scheduled'] ?? '',
        gate: json['departure']?['gate'],
        terminal: json['departure']?['terminal'],
        delay: json['departure']?['delay']?.toString(),
        airline: json['airline']?['name'] ?? '',
        departureCity: json['departure']?['airport'] ?? '',
        arrivalCity: json['arrival']?['airport'] ?? '',
      );
    } else {
      // For train data (you can integrate with train APIs like Deutsche Bahn, Amtrak, etc.)
      return Transport(
        id: json['train_id'] ?? '',
        type: 'train',
        number: json['train_number'] ?? '',
        status: json['status'] ?? 'unknown',
        departureAirport: json['departure_station'] ?? '',
        arrivalAirport: json['arrival_station'] ?? '',
        departureTime: json['departure_time'] ?? '',
        arrivalTime: json['arrival_time'] ?? '',
        delay: json['delay']?.toString(),
        airline: json['operator'] ?? '',
        departureCity: json['departure_city'] ?? '',
        arrivalCity: json['arrival_city'] ?? '',
      );
    }
  }

  IconData get typeIcon {
    return type == 'flight' ? Icons.flight : Icons.train;
  }

  bool get isDelayed {
    return status.toLowerCase() == 'delayed' || (delay != null && delay != '0');
  }

  String get routeInfo {
    return '$departureCity → $arrivalCity';
  }
}
