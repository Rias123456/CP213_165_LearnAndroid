import 'package:flutter/material.dart';

import 'app_constants.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('เกิดข้อผิดพลาด'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void showSuccessDialog(BuildContext context, {
  required String title,
  required String message,
  required String buttonText,
  required VoidCallback onConfirmed,
  Color iconColor = Colors.green,
  IconData icon = Icons.check_circle,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirmed();
            },
            child: Text(
              buttonText,
              style: const TextStyle(color: AppConstants.primaryPurple),
            ),
          ),
        ],
      );
    },
  );
}

void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ),
  );
}

String getFirestoreErrorMessage(dynamic error) {
  return error?.toString() ?? 'เกิดข้อผิดพลาดที่ไม่รู้จัก';
}
