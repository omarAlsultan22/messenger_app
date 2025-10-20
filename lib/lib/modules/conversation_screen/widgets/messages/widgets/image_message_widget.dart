import 'package:flutter/material.dart';
import '../models/conversation_model.dart';


class ImageMessageWidget extends StatelessWidget {
  final ConversationModel message;
  final bool isMe;
  final Function(String?) onShowFullImage;

  const ImageMessageWidget({
    required this.message,
    required this.isMe,
    required this.onShowFullImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final url = message.url;

    if (url == null) return const SizedBox();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        InkWell(
          onTap: () => onShowFullImage(url),
          child: Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                ),
                if (message.text!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      message.text!,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.dateTime ?? DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 12, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}