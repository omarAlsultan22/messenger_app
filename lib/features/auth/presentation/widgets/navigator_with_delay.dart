import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_durations.dart';


class NavigatorWithDelay {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Future.delayed(const Duration(seconds: AppDurations.oneSecond), () =>
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => link
          ),
        )
    );
  }
}