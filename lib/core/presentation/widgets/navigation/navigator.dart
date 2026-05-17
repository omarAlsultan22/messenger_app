import 'package:flutter/material.dart';
import '../../../../features/auth/presentation/screens/sign_in_screen.dart';


class BuildNavigator {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Future.delayed(const Duration(seconds: AppDurations.oneSecond), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => link
      ),
      );
    });
  }
}