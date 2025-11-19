import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


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
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow,
        size: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildVideoControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          VideoProgressIndicator(
            widget.videoController!,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            colors: const VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.grey,
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
          _formatDuration(widget.videoController!.value.position),
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          _formatDuration(widget.videoController!.value.duration),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
        color: Colors.grey,
      ),
      onPressed: _toggleEmojiPicker,
    );
  }

  Widget _buildTextInput() {
    return Expanded(
      child: TextField(
        controller: _textController,
        decoration: InputDecoration(
          hintText: 'اكتب رسالة...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        maxLines: null,
      ),
    );
  }

  Widget _buildSendButton() {
    return _isSending
        ? const Padding(
      padding: EdgeInsets.all(12.0),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    )
        : GestureDetector(
      onTap: _onSendPressed,
      child: const Padding(
        padding: EdgeInsets.all(12.0),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}