import 'dart:ui';

import 'package:flutter/material.dart';

class TransportInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String airport;
  final String time;
  final String? terminal;
  final String? gate;

  TransportInfo({
    required this.icon,
    required this.label,
    required this.airport,
    required this.time,
    this.terminal,
    this.gate,
  });

  String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade700.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.teal.shade100, size: 20),
                  SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                airport,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                formatTime(time),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (terminal != null || gate != null) ...[
                SizedBox(height: 4),
                Text(
                  '${terminal != null ? 'Terminal $terminal' : ''}${terminal != null && gate != null ? ' • ' : ''}${gate != null ? 'Gate $gate' : ''}',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
