import 'package:flutter/material.dart';


class MediaPickerWidget extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickVideo;
  final VoidCallback onTakePhoto;

  const MediaPickerWidget({
    required this.onPickImage,
    required this.onPickVideo,
    required this.onTakePhoto,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildOptions(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Choose Media',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildOptionItem(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: onPickImage,
            color: Colors.blue,
          ),
          _buildOptionItem(
            icon: Icons.video_library,
            label: 'Video',
            onTap: onPickVideo,
            color: Colors.green,
          ),
          _buildOptionItem(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: onTakePhoto,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}