import 'package:flutter/cupertino.dart';


abstract class AppPaddings {
  static const double _xs = 8.0;
  static const double _sm = 12.0;
  static const double _md = 16.0;
  static const double _lg = 20.0;
  static const double _xl = 24.0;

  static const EdgeInsets vSmall = EdgeInsets.all(_xs);
  static const EdgeInsets small = EdgeInsets.all(_sm);
  static const EdgeInsets medium = EdgeInsets.all(_md);
  static const EdgeInsets large = EdgeInsets.all(_lg);
  static const EdgeInsets xLarge = EdgeInsets.all(_xl);
  static const horizontalSymmetrical = EdgeInsets.symmetric(
      horizontal: _md);
  static const EdgeInsets verticalSymmetric = EdgeInsets.symmetric(
      vertical: _md);
}