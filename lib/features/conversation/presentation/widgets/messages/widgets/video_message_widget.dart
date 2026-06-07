import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import '../../../../data/models/conversation_model.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';
import 'package:test_app/features/conversation/constants/conversation_spaces.dart';
import 'package:test_app/features/conversation/constants/conversation_borders.dart';


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
        color: AppColors.grey_200,
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
              color: isMe ? AppColors.blue700 : AppColors.grey_300,
              borderRadius: AppBorders.borderRadius_12,
            ),
            child: ClipRRect(
              borderRadius: ConversationBorders.borderRadius_8,
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
                color: AppColors.white,
              ),
            ),

          Positioned(
            bottom: AppSpaces.xs,
            right: AppSpaces.xs,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: ConversationBorders.borderRadius_8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatTime.getTime(message.dateTime ?? DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: ConversationSpaces.fontSize_10,
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
              left: AppSpaces.xs,
              right: AppSpaces.xs,
              child: Text(
                message.text!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: AppColors.black,
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
}