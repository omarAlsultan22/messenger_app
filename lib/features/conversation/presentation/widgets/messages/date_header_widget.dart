import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import '../../../../../core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_paddings.dart';


class DateHeaderWidget extends StatelessWidget {
  final String date;

  const DateHeaderWidget({
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.verticalSymmetric,
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: AppColors.grey_400,
              thickness: 1,
            ),
          ),
          Padding(
            padding: AppPaddings.horizontalSymmetrical,
            child: Container(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? AppColors.grey_200
                    : AppColors.successGreen,
                borderRadius: AppBorders.borderRadius_12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: AppSizes.xs,
                  fontWeight: FontWeight.bold,
                  color: Theme
                      .of(context)
                      .brightness == Brightness.light
                      ? AppColors.grey_700
                      : AppColors.grey_300,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: AppColors.grey_400,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}