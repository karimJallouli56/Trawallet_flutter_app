import 'package:flutter/material.dart';

class ConfirmationCard extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;

  const ConfirmationCard({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,

    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationCard(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),

      actions: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 1, color: Colors.teal),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      actionsPadding: EdgeInsets.zero,
    );
  }
}
