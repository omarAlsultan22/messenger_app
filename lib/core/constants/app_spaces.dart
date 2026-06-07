import 'package:flutter/cupertino.dart';

abstract class AppSpaces {
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double _md = 24.0;
  static const double _lg = 30.0;
  static const double _xl = 32.0;
  static const double xxl = 40.0;

  static const SizedBox vertical_8 = SizedBox(height: xs);
  static const SizedBox vertical_16 = SizedBox(height: sm);
  static const SizedBox vertical_24 = SizedBox(height: _md);
  static const SizedBox vertical_30 = SizedBox(height: _lg);
  static const SizedBox vertical_32 = SizedBox(height: _xl);
  static const SizedBox vertical_40 = SizedBox(height: xxl);
}
