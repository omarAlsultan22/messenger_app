import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../data/models/message_group.dart';
import '../../../data/models/conversation_model.dart';
import '../../../../../core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_spaces.dart';
import 'package:test_app/core/constants/app_borders.dart';
import 'package:test_app/core/utils/format_duration.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import 'package:test_app/core/services/session_service.dart';
import '../../../../../core/data/models/last_message_model.dart';
import 'package:test_app/features/conversation/utils/format_time.dart';
import 'package:test_app/features/conversation/constants/conversation_borders.dart';


class ConversationMessagesList extends StatelessWidget {
  final bool beginFromEnd;
  final List<MessageGroup> conversations;
  final LastMessageModel lastMessageModel;
  final ScrollController scrollController;
  final Function(ConversationModel) onPlayAudio;
  final Function(ConversationModel) onStopAudio;
  final Function(String?, BuildContext) onShowFullImage;
  final Function(ConversationModel, Duration) onSeekAudio;
  final Function(ConversationModel, BuildContext) onShowFullVideo;
  final Function(ConversationModel, bool) onToggleMessageSelection;

  const ConversationMessagesList({
    super.key,
    required this.conversations,
    required this.beginFromEnd,
    required this.onPlayAudio,
    required this.onStopAudio,
    required this.onSeekAudio,
    required this.onShowFullImage,
    required this.onShowFullVideo,
    required this.scrollController,
    required this.lastMessageModel,
    required this.onToggleMessageSelection,
  });

  static const _borderRadius_8 = ConversationBorders.borderRadius_8;
  static const _textStyle = TextStyle(
      color: AppColors.white, fontSize: AppSizes.xs);

  static final _currentUid = SessionService().currentUid;

  @override
  Widget build(BuildContext context) {
    final isTyping = lastMessageModel.isTyping ?? false;
    return ListView.builder(
      controller: scrollController,
      reverse: beginFromEnd,
      itemCount: isTyping ? conversations.length + 1 : conversations.length,
      itemBuilder: (context, index) {
        final group = conversations[index];
        if (index < conversations.length) {
          return Column(
            children: [
              _buildDateHeader(group.date, context),
              ...group.exactMatches(
                  builder: (message) => _buildMessageItem(message, context)),
            ],
          );
        }
        else {
          return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  padding: const EdgeInsets.all(2.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery
                        .of(context)
                        .size
                        .width * 0.7,
                  ),
                  child: const Icon(
                      Icons.messenger_outlined,
                      color: AppColors.grey_300
                  )
              )
          );
        }
      },
    );
  }

  Widget _buildDateHeader(String? date, BuildContext context) {
    return date != '' ?
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme
              .of(context)
              .brightness == Brightness.light
              ? Colors.black12
              : AppColors.successGreen,
        ),
        padding: const EdgeInsets.all(6.0),
        child: Text(
          date!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ) : const SizedBox();
  }

  Widget _buildMessageItem(ConversationModel message, BuildContext context) {
    final isMe = message.senderId == _currentUid;

    return GestureDetector(
      onTap: () => onToggleMessageSelection(message, false),
      onLongPress: () => onToggleMessageSelection(message, true),
      child: Container(
        color: message.isActive ? AppColors.blue400 : AppColors.transparent,
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(message, isMe, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(ConversationModel message, bool isMe,
      BuildContext context) {
    switch (message.content) {
      case 'audio':
        return _buildAudioMessage(message, context);
      case 'image':
        return _buildImageMessage(message, context);
      case 'video':
        return _buildVideoMessage(message, context);
      default:
        return _buildTextMessage(message, isMe, context);
    }
  }

  Widget _buildTextMessage(ConversationModel message, bool isMe,
      BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? AppColors.blue700 : AppColors.grey_300,
          borderRadius: BorderRadius.only(
            topLeft: AppBorders.radius12,
            topRight: AppBorders.radius12,
            bottomLeft: isMe ? AppBorders.radius12 : Radius.zero,
            bottomRight: isMe ? Radius.zero : AppBorders.radius12,
          ),
        ),
        padding: AppPaddings.vSmall,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: [
                Text(
                  message.text!,
                  style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.black),
                ),
              ],
            ),
            _buildTimeWidget(message, context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(ConversationModel message, BuildContext context) {
    final isMe = message.senderId == _currentUid;
    final url = message.url;

    if (url == null) return const SizedBox();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        InkWell(
          onTap: () => onShowFullImage(url, context),
          child: message.url!.isNotEmpty
              ? Container(
            decoration: BoxDecoration(
              color: isMe ? AppColors.blue700 : AppColors.greyPrimaryValue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                if (message.text!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(message.text!),
                  ),
              ],
            ),
          )
              : ClipRRect(
            borderRadius: _borderRadius_8,
            child: Image.network(
              url,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        _buildTimeWidget(message, context),
      ],
    );
  }

  Widget _buildVideoMessage(ConversationModel message, BuildContext context) {
    if (message.videoController == null ||
        !message.videoController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final isMe = message.senderId == _currentUid;

    return GestureDetector(
      onTap: () => onShowFullVideo(message, context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          message.url!.isNotEmpty
              ? Container(
            decoration: BoxDecoration(
              color: isMe ? AppColors.blue700 : AppColors.greyPrimaryValue,
              borderRadius: _borderRadius_8,
            ),
            child: ClipRRect(
              borderRadius: _borderRadius_8,
              child: AspectRatio(
                aspectRatio: message.videoController!.value.aspectRatio,
                child: VideoPlayer(message.videoController!),
              ),
            ),
          )
              : ClipRRect(
            borderRadius: _borderRadius_8,
            child: AspectRatio(
              aspectRatio: message.videoController!.value.aspectRatio,
              child: VideoPlayer(message.videoController!),
            ),
          ),

          if (!message.videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: AppColors.white,
              ),
            ),

          Positioned(
            bottom: AppSpaces.xs,
            right: AppSpaces.xs,
            child: _buildTimeWidget(message, context),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(ConversationModel message, BuildContext context) {
    return Card(
      color: AppColors.blue700,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  message.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.white,
                ),
                onPressed: () async {
                  if (message.isPlaying) {
                    await onStopAudio(message);
                  } else {
                    await onPlayAudio(message);
                  }
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: message.positionNotifier,
                        builder: (context, position, child) {
                          final maxDuration = (message.playbackDuration
                              ?.inMilliseconds ?? 0).toDouble();
                          final currentPosition = position.toDouble().clamp(0.0,
                              maxDuration);

                          return Slider(
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
                            activeColor: AppColors.white,
                            inactiveColor: AppColors.grey_300,
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              FormatDuration.getDuration(Duration(
                                  milliseconds: message.positionNotifier.value
                                      .toInt()
                              )),
                              style: _textStyle,
                            ),
                            Text(
                              FormatDuration.getDuration(
                                  message.playbackDuration ?? Duration.zero),
                              style: _textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildTimeWidget(message, context),
        ],
      ),
    );
  }

  Widget _buildTimeWidget(ConversationModel message, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatTime.getTime(message.dateTime ?? DateTime.now()),
              style: TextStyle(
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? AppColors.black
                    : AppColors.white,
                fontSize: AppSizes.xs,
              ),
            ),
            if (message.senderId == _currentUid) ...[
              const SizedBox(width: 4.0),
              const Icon(Icons.done_all, size: 16.0),
            ],
          ],
        ),
      ),
    );
  }
}