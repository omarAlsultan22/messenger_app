import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_text_styles.dart';


class MediaPickerWidget extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onTakePhoto;

  const MediaPickerWidget({
    required this.onPickImage,
    required this.onPickVideo,
    required this.onTakePhoto,
    super.key,
  });

  //spaces
  static const _spacing60 = 60.0;
  static const _sizedBox = AppSpaces.vertical_16;

  //borders
  static const _radiusValue = 16.0;
  static const _borderRadius = Radius.circular(_radiusValue);

  //paddings
  static const _horizontalSymmetrical = AppPaddings.horizontalSymmetrical;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: _borderRadius,
            topRight: _borderRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sizedBox,
            _buildHeader(),
            _sizedBox,
            _buildOptions(context),
            _sizedBox,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: _horizontalSymmetrical,
      child: Text(
        'Choose Media',
        style: AppTextStyles.textStyle_18
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Padding(
      padding: _horizontalSymmetrical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionItem(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: onPickImage,
            color: AppColors.bluePrimaryValue,
          ),
          _buildOptionItem(
            icon: Icons.video_library,
            label: 'Video',
            onTap: onPickVideo,
            color: AppColors.green,
          ),
          _buildOptionItem(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: onTakePhoto,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: _spacing60,
            height: _spacing60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppBorders.borderRadius_30,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 30.0,
              color: color,
            ),
          ),
        ),
        AppSpaces.vertical_8,
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.xs,
            color: AppColors.grey_700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}