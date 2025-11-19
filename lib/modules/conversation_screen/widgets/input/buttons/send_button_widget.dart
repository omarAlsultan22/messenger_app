import 'package:flutter/material.dart';


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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isRecording
              ? Colors.red
              : (isEnabled ? Colors.blue : Colors.grey.shade300),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecording ? Icons.mic : Icons.send,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}