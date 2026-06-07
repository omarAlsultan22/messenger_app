import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';
import '../../../../../../core/constants/app_spaces.dart';


class SendButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onSend;
  final VoidCallback onRecordingStart;
  final VoidCallback onRecordingStop;
  final bool isRecording;

  const SendButtonWidget({
    required this.isEnabled,
    required this.onSend,
    required this.onRecordingStart,
    required this.onRecordingStop,
    required this.isRecording,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onSend : null,
      onLongPressStart: (_) => onRecordingStart(),
      onLongPressEnd: (_) => onRecordingStop(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: AppSpaces.xxl,
        height: AppSpaces.xxl,
        decoration: BoxDecoration(
          color: isRecording
              ? AppColors.redPrimaryValue
              : (isEnabled ? AppColors.bluePrimaryValue : AppColors.grey_300),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecording ? Icons.mic : Icons.send,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }
}