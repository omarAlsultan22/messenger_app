import '../constants/app_colors.dart';
import 'package:flutter/material.dart';


class AppTheme {
  static Color getAdaptiveColor(BuildContext context, {
    Color firstColor = AppColors.black,
    Color secondColor = AppColors.white
  }) {
    return Theme
        .of(context)
        .brightness == Brightness.light
        ? firstColor
        : secondColor;
  }
}
