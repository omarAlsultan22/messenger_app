import 'package:flutter/material.dart';


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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Icon(
                Icons.mic,
                size: 40 * _animation.value,
                color: Colors.red,
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _formatDuration(widget.recordingDuration),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recording...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Cancel',
                color: Colors.grey,
                onTap: widget.onCancelRecording,
              ),
              _buildActionButton(
                icon: Icons.check,
                label: 'Send',
                color: Colors.green,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}