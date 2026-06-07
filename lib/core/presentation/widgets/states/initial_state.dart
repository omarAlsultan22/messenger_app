import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';


class InitialStateWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  const InitialStateWidget({
    super.key,
    required this.text,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.menu,
            size: 100.0,
            color: Color(0xFFE0E0E0),
          ),
          Text(
            'No $text Found',
            style: const TextStyle(
              fontSize: AppSizes.sm,
              fontWeight: FontWeight.bold,
              color: AppColors.greyPrimaryValue,
            ),
          ),
        ],
      ),
    );
  }
}