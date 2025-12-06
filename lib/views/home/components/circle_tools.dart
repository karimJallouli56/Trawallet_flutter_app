import 'package:flutter/material.dart';

Widget circleTool({
  required BuildContext context,
  required IconData icon,
  required String label,
  required Color color,
  String? route, // optional
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 20),
    child: GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
