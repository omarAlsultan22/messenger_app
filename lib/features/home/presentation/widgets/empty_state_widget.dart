import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';


class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String assetPath;
  final VoidCallback? onActionPressed;
  final String actionText;

  const EmptyStateWidget({
    required this.title,
    required this.message,
    this.assetPath = 'assets/images/empty_chat.png',
    this.onActionPressed,
    this.actionText = 'Add Friends',
    super.key,
  });

  static const _spacing150 = 150.0;
  static const _spacing24 = AppSpaces.vertical_24;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: _spacing150,
              height: _spacing150,
              color: AppColors.grey_300,
            ),
            _spacing24,
            Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.greyPrimaryValue,
              ),
            ),
            AppSpaces.vertical_8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppSizes.sm,
                color: AppColors.grey_600,
              ),
            ),
            if (onActionPressed != null) ...[
              _spacing24,
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimaryValue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}