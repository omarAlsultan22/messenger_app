import 'package:flutter/material.dart';
import '../models/conversation_model.dart';


class AudioMessageWidget extends StatelessWidget {
  final ConversationModel message;
  final bool isMe;
  final Function(ConversationModel) onPlayAudio;
  final Function(ConversationModel) onStopAudio;
  final Function(ConversationModel, Duration) onSeekAudio;

  const AudioMessageWidget({
    required this.message,
    required this.isMe,
    required this.onPlayAudio,
    required this.onStopAudio,
    required this.onSeekAudio,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.shade700 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  message.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isMe ? Colors.white : Colors.blue,
                  size: 24,
                ),
                onPressed: () async {
                  if (message.isPlaying) {
                    await onStopAudio(message);
                  } else {
                    await onPlayAudio(message);
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: message.positionNotifier,
                      builder: (context, position, child) {
                        final maxDuration = (message.playbackDuration?.inMilliseconds ?? 0).toDouble();
                        final currentPosition = position.toDouble().clamp(0.0, maxDuration);

                        return Column(
                          children: [
                            Slider(
                              value: maxDuration > 0 ? currentPosition : 0.0,
                              min: 0.0,
                              max: maxDuration,
                              onChanged: (value) {
                                message.positionNotifier.value = value;
                              },
                              onChangeEnd: (value) async {
                                await onSeekAudio(message, Duration(milliseconds: value.toInt()));
                              },
                              activeColor: isMe ? Colors.white : Colors.blue,
                              inactiveColor: Colors.grey[300],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(Duration(
                                        milliseconds: message.positionNotifier.value.toInt()
                                    )),
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(message.playbackDuration ?? Duration.zero),
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _formatTime(message.dateTime ?? DateTime.now()),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 12, color: Colors.white70),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}