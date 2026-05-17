import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../../models/conversation_model.dart';


class VideoMessageWidget extends StatelessWidget {
  final ConversationModel message;
  final bool isMe;
  final Function(ConversationModel) onShowFullVideo;

  const VideoMessageWidget({
    required this.message,
    required this.isMe,
    required this.onShowFullVideo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (message.videoController == null ||
        !message.videoController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      onTap: () => onShowFullVideo(message),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: message.videoController!.value.aspectRatio,
                child: VideoPlayer(message.videoController!),
              ),
            ),
          ),

          if (!message.videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),

          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.dateTime ?? DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 12, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),

          if (message.text!.isNotEmpty)
            Positioned(
              bottom: 40,
              left: 8,
              right: 8,
              child: Text(
                message.text!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}