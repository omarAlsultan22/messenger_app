import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';


class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({
    this.message = 'Loading chats...',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          AppSpaces.vertical_16,
          Text(
            message,
            style: const TextStyle(
              fontSize: AppSizes.sm,
              color: AppColors.greyPrimaryValue,
            ),
          ),
        ],
      ),
    );
  }
}