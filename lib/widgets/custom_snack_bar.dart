import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, bool isSuccess) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
    backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    duration: const Duration(seconds: 2),
    elevation: 6,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
