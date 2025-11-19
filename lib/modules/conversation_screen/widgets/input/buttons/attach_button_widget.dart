import 'package:flutter/material.dart';


class AttachButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const AttachButtonWidget({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.attach_file,
          color: Colors.grey,
          size: 20,
        ),
      ),
      onPressed: onPressed,
    );
  }
}