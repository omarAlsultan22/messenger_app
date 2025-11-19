import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../layouts/publishing_confirmation_layout.dart';


class PublishingConfirmationScreen extends StatelessWidget {
  final File file;
  final VideoPlayerController? videoController;
  final Widget buildEmojiPicker;
  final Function(String?) onTap;

  const PublishingConfirmationScreen({
    required this.file,
    required this.buildEmojiPicker,
    required this.onTap,
    this.videoController,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال الوسائط'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PublishingConfirmationLayout(
        file: file,
        videoController: videoController,
        buildEmojiPicker: buildEmojiPicker,
        onTap: onTap,
      ),
    );
  }
}