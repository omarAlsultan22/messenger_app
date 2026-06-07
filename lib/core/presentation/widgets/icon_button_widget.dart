import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';


class IconButtonWidget extends StatelessWidget {
  const IconButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.white),
      onPressed: () => Navigator.pop(context),
      splashRadius: 12.0,
    );
  }
}