import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Widget? input;
  final String confirmText;

  const AlertCard({
    super.key,
    required this.title,
    this.message,
    required this.icon,
    required this.onConfirm,
    required this.onCancel,
    this.input,
    this.confirmText = "Confirm",
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of content widgets
    final List<Widget> contentWidgets = [];

    if (message != null) {
      contentWidgets.add(
        Text(
          message!,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      );
    }

    if (input != null) {
      // Add some spacing if both message and input are present
      if (message != null) contentWidgets.add(const SizedBox(height: 12));
      contentWidgets.add(input!);
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),

      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      content: contentWidgets.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentWidgets,
            )
          : null,

      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmText,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
