import 'app_sizes.dart';
import 'package:flutter/material.dart';


abstract class AppTextStyles {
  static const TextStyle textStyle_12 = TextStyle(
    fontSize: AppSizes.xs,
  );
  static const TextStyle textStyle_16 = TextStyle(
    fontSize: AppSizes.sm,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle textStyle_18 = TextStyle(
    fontSize: AppSizes.md,
    fontWeight: FontWeight.bold,
  );
}