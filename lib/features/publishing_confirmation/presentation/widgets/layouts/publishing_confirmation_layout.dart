import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/utils/format_duration.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/constants/app_text_styles.dart';


class PublishingConfirmationLayout extends StatefulWidget {
  final File file;
  final VideoPlayerController? videoController;
  final Widget buildEmojiPicker;
  final Function(String?) onTap;

  const PublishingConfirmationLayout({
    required this.file,
    required this.buildEmojiPicker,
    required this.onTap,
    this.videoController,
    super.key
  });

  @override
  State<PublishingConfirmationLayout> createState() => _PublishingConfirmationLayoutState();
}

class _PublishingConfirmationLayoutState extends State<PublishingConfirmationLayout> {
  final TextEditingController _textController = TextEditingController();
  bool _showEmojiPicker = false;
  bool _isSending = false;

  static const _symmetric = EdgeInsets.symmetric(
      horizontal: AppSpaces.sm, vertical: AppSpaces.xs);

  @override
  void initState() {
    super.initState();
    if (widget.videoController != null) {
      widget.videoController!.addListener(_videoListener);
    }
  }

  @override
  void dispose() {
    if (widget.videoController != null) {
      widget.videoController!.removeListener(_videoListener);
    }
    _textController.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.videoController != null
              ? _buildVideoPreview()
              : _buildImagePreview(),
        ),
        if (_showEmojiPicker) widget.buildEmojiPicker,
        const Divider(height: 1),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Image.file(
      widget.file,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  Widget _buildVideoPreview() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleVideoPlayback,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: widget.videoController!.value.aspectRatio,
                  child: VideoPlayer(widget.videoController!),
                ),
                if (!widget.videoController!.value.isPlaying)
                  _buildPlayButton(),
              ],
            ),
          ),
        ),
        _buildVideoControls(),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black..withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow,
        size: 50,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildVideoControls() {
    return Padding(
      padding: _symmetric,
      child: Column(
        children: [
          VideoProgressIndicator(
            widget.videoController!,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: AppSpaces.xs),
            colors: const VideoProgressColors(
              playedColor: AppColors.bluePrimaryValue,
              bufferedColor: AppColors.greyPrimaryValue,
              backgroundColor: AppColors.greyPrimaryValue,
            ),
          ),
          _buildTimeIndicator(),
        ],
      ),
    );
  }

  Widget _buildTimeIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FormatDuration.getDuration(widget.videoController!.value.position),
          style: AppTextStyles.textStyle_12,
        ),
        Text(
          FormatDuration.getDuration(widget.videoController!.value.duration),
          style: AppTextStyles.textStyle_12,
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: _symmetric,
      child: Row(
        children: [
          _buildEmojiButton(),
          _buildTextInput(),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildEmojiButton() {
    return IconButton(
      icon: Icon(
        _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
        color: AppColors.greyPrimaryValue,
      ),
      onPressed: _toggleEmojiPicker,
    );
  }

  Widget _buildTextInput() {
    return Expanded(
      child: TextField(
        controller: _textController,
        decoration: const InputDecoration(
          hintText: 'اكتب رسالة...',
          border: OutlineInputBorder(
            borderRadius: AppBorders.borderRadius_30,
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: AppPaddings.horizontalSymmetrical,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }

  Widget _buildSendButton() {
    return _isSending
        ? const Padding(
      padding: AppPaddings.small,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    )
        : GestureDetector(
      onTap: _onSendPressed,
      child: const Padding(
        padding: AppPaddings.small,
        child: Icon(Icons.send, color: Colors.blue),
      ),
    );
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void _toggleVideoPlayback() {
    setState(() {
      if (widget.videoController!.value.isPlaying) {
        widget.videoController!.pause();
      } else {
        widget.videoController!.play();
      }
    });
  }

  void _onSendPressed() {
    if (_isSending) return;

    setState(() => _isSending = true);

    widget.onTap(_textController.text);
    _resetVideoState();
  }

  void _resetVideoState() {
    if (widget.videoController != null) {
      if (widget.videoController!.value.isPlaying) {
        widget.videoController!.pause();
      }
      widget.videoController!.seekTo(Duration.zero);
    }
  }
}