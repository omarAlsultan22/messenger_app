import 'package:flutter/material.dart';


class LoadingWidget {
  static const _spacing = 24.0;
  static const sizedBox = SizedBox(
    height: _spacing,
    width: _spacing,
    child: CircularProgressIndicator(
      strokeWidth: 3,
    ),
  );
}