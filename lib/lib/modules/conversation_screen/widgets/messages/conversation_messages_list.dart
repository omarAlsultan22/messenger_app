import 'package:flutter/material.dart';
import '../models/conversation_model.dart';


class ConversationMessagesList extends StatelessWidget {
  final List<ConversationGroup> conversations;
  final ScrollController scrollController;
  final bool beginFromEnd;
  final Function(ConversationModel, bool) onToggleMessageSelection;
  final Function(ConversationModel) onPlayAudio;
  final Function(ConversationModel) onStopAudio;
  final Function(ConversationModel, Duration) onSeekAudio;
  final Function(String?, BuildContext) onShowFullImage;
  final Function(ConversationModel, BuildContext) onShowFullVideo;

  const ConversationMessagesList({
    required this.conversations,
    required this.scrollController,
    required this.beginFromEnd,
    required this.onToggleMessageSelection,
    required this.onPlayAudio,
    required this.onStopAudio,
    required this.onSeekAudio,
    required this.onShowFullImage,
    required this.onShowFullVideo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: beginFromEnd,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final group = conversations[index];
        return Column(
          children: [
            _buildDateHeader(group.title, context),
            ...group.messages.map((message) => _buildMessageItem(message, context)),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black12
              : Colors.grey.shade800,
        ),
        padding: const EdgeInsets.all(6.0),
        child: Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ConversationModel message, BuildContext context) {
    final isMe = message.senderId == UserDetails.userId;

    return GestureDetector(
      onTap: () => onToggleMessageSelection(message, false),
      onLongPress: () => onToggleMessageSelection(message, true),
      child: Container(
        color: message.isActive ? Colors.blue.shade400 : Colors.transparent,
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
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

  Widget _buildMessageContent(ConversationModel message, bool isMe, BuildContext context) {
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

  Widget _buildTextMessage(ConversationModel message, bool isMe, BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade700 : Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: [
                Text(
                  message.text!,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
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
    final isMe = message.senderId == UserDetails.userId;
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
              color: isMe ? Colors.blue.shade700 : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.url!,
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
            borderRadius: BorderRadius.circular(8),
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

    final isMe = message.senderId == UserDetails.userId;

    return GestureDetector(
      onTap: () => onShowFullVideo(message, context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          message.url!.isNotEmpty
              ? Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.blue.shade700 : Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: message.videoController!.value.aspectRatio,
                child: VideoPlayer(message.videoController!),
              ),
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: message.videoController!.value.aspectRatio,
              child: VideoPlayer(message.videoController!),
            ),
          ),

          if (!message.videoController!.value.isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),

          Positioned(
            bottom: 8,
            right: 8,
            child: _buildTimeWidget(message, context),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(ConversationModel message, BuildContext context) {
    return Card(
      color: Colors.blue.shade700,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  message.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
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
                          final maxDuration = (message.playbackDuration?.inMilliseconds ?? 0).toDouble();
                          final currentPosition = position.toDouble().clamp(0.0, maxDuration);

                          return Slider(
                            value: maxDuration > 0 ? currentPosition : 0.0,
                            min: 0.0,
                            max: maxDuration,
                            onChanged: (value) {
                              message.positionNotifier.value = value;
                            },
                            onChangeEnd: (value) async {
                              await onSeekAudio(message, Duration(milliseconds: value.toInt()));
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey[300],
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(Duration(
                                  milliseconds: message.positionNotifier.value.toInt()
                              )),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(message.playbackDuration ?? Duration.zero),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
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
              _formatTime(message.dateTime ?? DateTime.now()),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 12,
              ),
            ),
            if (message.senderId == UserDetails.userId) ...[
              const SizedBox(width: 4),
              const Icon(Icons.done_all, size: 16),
            ],
          ],
        ),
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