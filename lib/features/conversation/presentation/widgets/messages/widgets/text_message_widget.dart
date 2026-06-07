import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import '../../../../data/models/conversation_model.dart';
import '../../../../../../core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';
import 'package:test_app/features/conversation/constants/conversation_colors.dart';


class TextMessageWidget extends StatelessWidget {
  final ConversationModel message;
  final bool isMe;

  const TextMessageWidget({
    required this.message,
    required this.isMe,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? AppColors.blue700 : AppColors.grey_300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        padding: AppPaddings.small,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text!,
              style: TextStyle(
                color: isMe ? AppColors.white : AppColors.black,
                fontSize: AppSizes.sm,
              ),
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  FormatTime.getTime(message.dateTime ?? DateTime.now()),
                  style: TextStyle(
                    color: isMe
                        ? ConversationColors.white70
                        : ConversationColors.black54,
                    fontSize: AppSizes.xs,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4.0),
                  const Icon(Icons.done_all, size: 14,
                      color: ConversationColors.white70),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}