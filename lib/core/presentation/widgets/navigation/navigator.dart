import 'package:flutter/material.dart';


class BuildNavigator {
  static void build({
    required Widget link,
    required BuildContext context,
  }) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => link)
    );
  }
}