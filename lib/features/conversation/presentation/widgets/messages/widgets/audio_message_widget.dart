import 'package:flutter/material.dart';
import '../../../../data/models/conversation_model.dart';
import 'package:test_app/core/utils/format_duration.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';
import 'package:test_app/features/conversation/constants/conversation_colors.dart';
import 'package:test_app/features/conversation/constants/conversation_spaces.dart';


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

  static const _white70 = ConversationColors.white70;
  static const _black54 = ConversationColors.black54;
  static const _fontSize = ConversationSpaces.fontSize_10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? Colors.blue.shade700 : Colors.grey.shade300,
        borderRadius: AppBorders.borderRadius_12,
      ),
      padding: AppPaddings.small,
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
               const SizedBox(width: ConversationSpaces.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: message.positionNotifier,
                      builder: (context, position, child) {
                        final maxDuration = (message.playbackDuration
                            ?.inMilliseconds ?? 0).toDouble();
                        final currentPosition = position.toDouble().clamp(
                            0.0, maxDuration);

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
                                await onSeekAudio(message,
                                    Duration(milliseconds: value.toInt()));
                              },
                              activeColor: isMe ? Colors.white : Colors.blue,
                              inactiveColor: Colors.grey[300],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    FormatDuration.getDuration(Duration(
                                        milliseconds: message.positionNotifier
                                            .value.toInt()
                                    )),
                                    style: TextStyle(
                                      color: isMe ? _white70 : _black54,
                                      fontSize: _fontSize,
                                    ),
                                  ),
                                  Text(
                                    FormatDuration.getDuration(
                                        message.playbackDuration ??
                                            Duration.zero),
                                    style: TextStyle(
                                      color: isMe ? _white70 : _black54,
                                      fontSize: _fontSize,
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
                FormatTime.getTime(message.dateTime ?? DateTime.now()),
                style: TextStyle(
                  color: isMe ? _white70 : _black54,
                  fontSize: _fontSize,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 12, color: _white70),
              ],
            ],
          ),
        ],
      ),
    );
  }
}