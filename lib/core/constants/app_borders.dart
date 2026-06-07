import 'package:flutter/cupertino.dart';


abstract class AppBorders {
  static const double _vSmall = 12.0;
  static const double _small = 16.0;
  static const double _medium = 30.0;
  static const double _large = 50.0;

  static const radius12 = Radius.circular(_vSmall);
  static const BorderRadius borderRadius_12 = BorderRadius.all(radius12);
  static const BorderRadius borderRadius_16 = BorderRadius.all(
      Radius.circular(_small));
  static const BorderRadius borderRadius_30 = BorderRadius.all(
      Radius.circular(_medium));
  static const BorderRadius borderRadius_50 = BorderRadius.all(
      Radius.circular(_large));
}