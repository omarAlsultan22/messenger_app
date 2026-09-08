import 'package:flutter/material.dart';


class NavigatorWithDelay {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Future.delayed(const Duration(seconds: 1), () =>
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => link
          ),
        )
    );
  }
}