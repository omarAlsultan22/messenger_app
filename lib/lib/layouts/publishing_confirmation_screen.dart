import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PublishingConfirmationScreen extends StatefulWidget {
  final File file;
  final VideoPlayerController? videoController;
  final Widget buildEmojiPicker;
  final Function(String?) onTap;

  const PublishingConfirmationScreen({
    required this.file,
    required this.buildEmojiPicker,
    required this.onTap,
    this.videoController,
    super.key});

  @override
  State<PublishingConfirmationScreen> createState() => _PublishingConfirmationScreenState();
}

class _PublishingConfirmationScreenState extends State<PublishingConfirmationScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _showEmojiPicker = false;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoController != null) {
      widget.videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: widget.videoController != null
                ? _buildVideoPreview()
                : Image.file(widget.file),
          ),
          if (_showEmojiPicker) widget.buildEmojiPicker,
          const Divider(height: 1),
          _buildInputArea(),
        ],
      ),
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.white
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Video controls
        Padding(
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

              _buildMediaTimeIndicator(
                position: widget.videoController!.value.position,
                duration: widget.videoController!.value.duration,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTimeIndicator({
    required Duration position,
    required Duration duration,
  }) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(position.inMinutes.remainder(60));
    final seconds = twoDigits(position.inSeconds.remainder(60));
    final totalMinutes = twoDigits(duration.inMinutes.remainder(60));
    final totalSeconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$minutes:$seconds',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '$totalMinutes:$totalSeconds',
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
          IconButton(
            icon: Icon(
              _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() => _showEmojiPicker = !_showEmojiPicker);
            },
          ),
          Expanded(
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
            ),
          ),
          isSending ?
          const Center(child: CircularProgressIndicator()):
          GestureDetector(
            onTap: () {
              widget.onTap(_textController.text);
              _handleVideoDialogClosing();
              setState(() => isSending = true);
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
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

  void _handleVideoDialogClosing() {
    if (widget.videoController != null) {
      if (widget.videoController!.value.isPlaying) {
        widget.videoController!.pause();
      }
      widget.videoController!.seekTo(Duration.zero);
    }
  }
}