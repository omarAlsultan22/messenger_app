import 'package:flutter/material.dart';
import '../../shared/components/components.dart';


class ConversationInputArea extends StatelessWidget {
  final TextEditingController textController;
  final bool isSending;
  final bool showEmojiPicker;
  final bool micIsActive;
  final VoidCallback onSendText;
  final VoidCallback onToggleRecording;
  final VoidCallback onToggleEmojiPicker;
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onTakePhoto;
  final VoidCallback onShowMediaPicker;

  const ConversationInputArea({
    required this.textController,
    required this.isSending,
    required this.showEmojiPicker,
    required this.micIsActive,
    required this.onSendText,
    required this.onToggleRecording,
    required this.onToggleEmojiPicker,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onTakePhoto,
    required this.onShowMediaPicker,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          _buildEmojiButton(),
          Expanded(child: _buildTextInput()),
          _buildAttachButton(context),
          _buildCameraButton(),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildEmojiButton() {
    return IconButton(
      icon: Icon(
        showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
        color: Colors.grey,
      ),
      onPressed: onToggleEmojiPicker,
    );
  }

  Widget _buildTextInput() {
    return buildInputField(
      context: context,
      controller: textController,
      decoration: InputDecoration(
        hintText: 'اكتب رسالة...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildAttachButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: () => onShowMediaPicker(context),
    );
  }

  Widget _buildCameraButton() {
    return IconButton(
      icon: const Icon(Icons.camera_alt),
      onPressed: onTakePhoto,
    );
  }

  Widget _buildSendButton() {
    return isSending
        ? const Padding(
      padding: EdgeInsets.all(8.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    )
        : GestureDetector(
      onTap: textController.text.isNotEmpty ? onSendText : null,
      onLongPress: onToggleRecording,
      onLongPressUp: onToggleRecording,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: micIsActive ? Colors.red : null,
        ),
        padding: const EdgeInsets.all(12.0),
        child: Icon(
          textController.text.isNotEmpty ? Icons.send : Icons.mic,
          color: micIsActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}