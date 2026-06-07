import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_text_styles.dart';
import 'package:test_app/features/conversation/constants/conversation_borders.dart';


class EmojiPickerWidget extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onEmojiPickerClosed;

  const EmojiPickerWidget({
    required this.textController,
    required this.onEmojiPickerClosed,
    super.key,
  });

  @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget> {
  static const List<String> _commonEmojis = [
    '😀', '😂', '🥰', '😍', '🤩', '😎', '🥳', '😊', '😇', '🙂',
    '🤔', '😴', '🥺', '😭', '😡', '🤯', '😱', '🤗', '👋', '👍',
    '👏', '🙏', '💪', '👀', '👅', '👄', '💖', '🔥', '⭐', '🎉',
    '💯', '✨', '🎂', '🍕', '☕', '📱', '💻', '🎧', '🏀', '⚽'
  ];

  static const _spacing8 = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0,
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(
            color: AppColors.grey_300,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildEmojiGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40.0,
      decoration: const BoxDecoration(
        color: AppColors.grey_100,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey_300,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
           const Text(
            'Emojis',
            style: AppTextStyles.textStyle_16,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20.0),
            onPressed: widget.onEmojiPickerClosed,
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid() {
    return GridView.builder(
      padding: AppPaddings.medium,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: _spacing8,
        mainAxisSpacing: _spacing8,
      ),
      itemCount: _commonEmojis.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.textController.text += _commonEmojis[index];
          },
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: ConversationBorders.borderRadius_8,
              color: AppColors.grey_100,
            ),
            child: Center(
              child: Text(
                _commonEmojis[index],
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        );
      },
    );
  }
}