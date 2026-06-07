import 'package:flutter/material.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/presentation/widgets/text_form_field.dart';


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
  final Function(BuildContext) onShowMediaPicker;

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

  static const _spacing20 = 20.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        children: [
          _buildEmojiButton(),
          Expanded(child: _buildTextInput(context)),
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
        color: AppColors.greyPrimaryValue,
      ),
      onPressed: onToggleEmojiPicker,
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return BuildInputField(
      controller: textController,
      decoration: const InputDecoration(
        hintText: 'اكتب رسالة...',
        border: OutlineInputBorder(
          borderRadius: AppBorders.borderRadius_30,
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: AppPaddings.horizontalSymmetrical,
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
      padding: AppPaddings.vSmall,
      child: SizedBox(
        width: _spacing20,
        height: _spacing20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: AppColors.white,
        ),
      ),
    )
        : GestureDetector(
      onTap: textController.text.isNotEmpty ? onSendText : null,
      onLongPress: onToggleRecording,
      onLongPressUp: onToggleRecording,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppBorders.borderRadius_50,
          color: micIsActive ? AppColors.redPrimaryValue : null,
        ),
        padding: AppPaddings.small,
        child: Icon(
          textController.text.isNotEmpty ? Icons.send : Icons.mic,
          color: micIsActive ? AppColors.white : AppColors.greyPrimaryValue,
        ),
      ),
    );
  }
}