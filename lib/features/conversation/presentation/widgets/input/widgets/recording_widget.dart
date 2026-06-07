import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/utils/format_duration.dart';
import 'package:test_app/core/constants/app_paddings.dart';


class RecordingWidget extends StatefulWidget {
  final Duration recordingDuration;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;

  const RecordingWidget({
    required this.recordingDuration,
    required this.onStopRecording,
    required this.onCancelRecording,
    super.key,
  });

  @override
  State<RecordingWidget> createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<RecordingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const _spacing50 = 50.0;
  static const _spacingVertical = AppSpaces.vertical_16;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..repeat(reverse: true);

    _animation =
        Tween<double>(begin: 0.8, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPaddings.medium,
      decoration: BoxDecoration(
        color: AppColors.red_50,
        borderRadius: AppBorders.borderRadius_16,
        border: Border.all(color: AppColors.red_200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Icon(
                Icons.mic,
                size: 40.0 * _animation.value,
                color: AppColors.redPrimaryValue,
              );
            },
          ),
          _spacingVertical,
          Text(
            FormatDuration.getDuration(widget.recordingDuration),
            style: const TextStyle(
              fontSize: AppSizes.md,
              fontWeight: FontWeight.bold,
              color: AppColors.redPrimaryValue,
            ),
          ),
          _spacingVertical,
          const Text(
            'Recording...',
            style: TextStyle(
              fontSize: AppSizes.sm,
              color: AppColors.grey_600,
            ),
          ),
          _spacingVertical,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Cancel',
                color: AppColors.greyPrimaryValue,
                onTap: widget.onCancelRecording,
              ),
              _buildActionButton(
                icon: Icons.check,
                label: 'Send',
                color: AppColors.green,
                onTap: widget.onStopRecording,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: _spacing50,
            height: _spacing50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.xs,
            color: color,
          ),
        ),
      ],
    );
  }
}