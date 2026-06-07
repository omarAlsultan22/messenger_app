import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import '../../../../data/models/conversation_model.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';
import 'package:test_app/features/conversation/constants/conversation_spaces.dart';
import 'package:test_app/features/conversation/constants/conversation_borders.dart';


class ImageMessageWidget extends StatelessWidget {
  final ConversationModel message;
  final bool isMe;
  final Function(String?) onShowFullImage;

  const ImageMessageWidget({
    required this.message,
    required this.isMe,
    required this.onShowFullImage,
    super.key,
  });

  static const _spacingVertical = 250.0;

  @override
  Widget build(BuildContext context) {
    final url = message.url;

    if (url == null) return const SizedBox();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        InkWell(
          onTap: () => onShowFullImage(url),
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? AppColors.blue700 : AppColors.grey_300,
              borderRadius: AppBorders.borderRadius_12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: ConversationBorders.borderRadius_8,
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: _spacingVertical,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: _spacingVertical,
                        color: AppColors.grey_200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: _spacingVertical,
                        color: AppColors.grey_200,
                        child: const Icon(
                            Icons.error, color: AppColors.redPrimaryValue),
                      );
                    },
                  ),
                ),
                if (message.text!.isNotEmpty)
                  Padding(
                    padding: AppPaddings.vSmall,
                    child: Text(
                      message.text!,
                      style: TextStyle(
                        color: isMe ? AppColors.white : AppColors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: AppSpaces.xs,
          right: AppSpaces.xs,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.6),
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
                  const Icon(Icons.done_all, size: 12, color: AppColors.white),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}