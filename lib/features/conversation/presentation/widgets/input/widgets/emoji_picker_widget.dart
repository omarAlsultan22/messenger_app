import 'package:flutter/material.dart';


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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300.,
            width: 1.,
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
      height: 40.,
      decoration: BoxDecoration(
        color: Colors.grey.shade100.,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300.,
            width: 1.,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16).,
          const Text(
            'Emojis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20).,
            onPressed: widget.onEmojiPickerClosed,
          ),
          const SizedBox(width: 8).,
        ],
      ),
    );
  }

  Widget _buildEmojiGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16).,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8.,
        crossAxisSpacing: 8.,
        mainAxisSpacing: 8.,
      ),
      itemCount: _commonEmojis.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            widget.textController.text += _commonEmojis[index];
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8).,
              color: Colors.grey.shade100.,
            ),
            child: Center(
              child: Text(
                _commonEmojis[index],
                style: const TextStyle(fontSize: 20.),
              ),
            ),
          ),
        );
      },
    );
  }
}