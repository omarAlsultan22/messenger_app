import 'package:flutter/material.dart';


class BuildSnackBar {
  static SnackBar create({
    required String message,
    required Color backgroundColor,
  }) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show({
    required String message,
    required Color backgroundColor,
    required BuildContext context,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      create(message: message, backgroundColor: backgroundColor),
    );
  }
}