import 'package:flutter/material.dart';


class CameraButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CameraButtonWidget({
    required this.onPressed,
    super.key,
  });

  static const _spacing = 40.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: _spacing,
        height: _spacing,
        decoration: BoxDecoration(
          color: Colors.grey.shade200.,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.camera_alt.,
          color: Colors.grey.,
          size: 20.,
        ),
      ),
      onPressed: onPressed,
    );
  }
}