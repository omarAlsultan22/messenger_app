import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spaces.dart';


class CameraButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CameraButtonWidget({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: AppSpaces.xxl,
        height: AppSpaces.xxl,
        decoration: const BoxDecoration(
          color: AppColors.grey_200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt,
          color: AppColors.greyPrimaryValue,
          size: 20,
        ),
      ),
      onPressed: onPressed,
    );
  }
}