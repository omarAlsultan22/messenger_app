import 'dart:async';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/lib/layouts/publishing_confirmation_screen.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import 'package:video_player/video_player.dart';
import 'package:test_app/lib/models/conversation_model.dart';
import 'package:test_app/lib/modules/chat_screen/cubit.dart';
import 'package:test_app/lib/shared/components/components.dart';
import '../models/last_message_model.dart';
import '../modules/audio_recorder/audio_screen.dart';
import '../modules/edit_personal_account/edit_personal_account.dart';
import '../modules/notification_service/notification_service.dart';
import '../modules/online_status_service/online_status_service.dart';
import '../shared/components/constants.dart';


class VideoPlayerManager {
  VideoPlayerController? _controller;

  Future<void> init(String path) async {
    _controller = VideoPlayerController.file(File(path));
    await _controller?.initialize();
  }

  void play() => _controller?.play();
  void pause() => _controller?.pause();

  Future<void> seek(Duration position) async {
    await _controller?.seekTo(position);
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  VideoPlayerController? get controller => _controller;
}

class ConversationLayout extends StatefulWidget {
  final LastMessageModel lastMessageModel;
  final OnlineStatusService onlineStatusService;

  const ConversationLayout({
    required this.lastMessageModel,
    required this.onlineStatusService,
    super.key
  });

  @override
  State<ConversationLayout> createState() => _ConversationLayoutState();
}

class _ConversationLayoutState extends State<ConversationLayout> {
  final AudioPlayerManager _audioManager = AudioPlayerManager();
  ConversationModel? _currentlyPlayingAudio;
  AudioPlayerManager? _fullScreenAudioManager;
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  StreamSubscription<PlaybackDisposition>? _playbackSubscription;



  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _micIsActive = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  Timer? _progressTimer;


  // Message selection variables
  int selectedItems = 0;
  final List<String> _selectedMessageIds = [];

  // UI state variables
  bool _isSending = false;
  bool _showEmojiPicker = false;
  bool _isMuted = false;
  bool _isLoadingOldMessages = true;
  bool beginFromEnd = true;
  bool _positionListenerAdded = false; // ← هنا


  Color? bgColor;
  String? bgImage;

  // Controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  VideoPlayerController? _fullScreenVideoController;

  // Services and utilities
  final NotificationService _notificationService = NotificationService();
  SharedPreferences? _prefs;
  late ConversationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateTypingStatus);
    _scrollController.addListener(_handleScroll);
    _loadMuteStatus();
    _loadBackgroundSettings();
    _audioRecorder.init();
    _audioPlayer.openPlayer();
  }

  @override
  void dispose() {
    _textController.removeListener(_updateTypingStatus);
    _fullScreenVideoController?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _recordingTimer?.cancel();
    _cubit.clearConversationsList();
    _fullScreenAudioManager?.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioManager.dispose();
    _audioPlayer.closePlayer();
    _playbackSubscription?.cancel();
    super.dispose();
  }



  Future<void> _toggleRecording() async {
    if (_micIsActive) {
      _audioPath = await _audioRecorder.stopRecording();
      _recordingTimer?.cancel();

      final durationToSend = _recordingDuration;

      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });

      await _sendAudioMessage(duration: durationToSend);
    } else {
      _recordingDuration = Duration.zero;
      var status = await Permission.microphone.status;
      if(!status.isGranted){
        setState(() => _micIsActive = true);
      }
      await _audioRecorder.startRecording();

      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
        });
      });

      setState(() => _isRecording = true);
    }
    setState(() => _micIsActive = !_micIsActive);
  }

  Future<void> _stopAllPlaybacks() async {
    await _audioPlayer.stopPlayer();
    await _playbackSubscription?.cancel();

    if (!mounted) return;
    setState(() {
      _currentlyPlayingAudio?.updatePlaybackState(playing: false, position: Duration.zero);
      _currentlyPlayingAudio = null;
    });
  }

  Future<void> _playRecording(ConversationModel message) async {
    try {
      await _stopAllPlaybacks();

      if (!_audioPlayer.isOpen()) {
        await _audioPlayer.openPlayer();
      }

      await _audioPlayer.startPlayer(
        fromURI: message.url,
        whenFinished: () => _resetPlayback(message),
      );

      _playbackSubscription = _audioPlayer.onProgress?.listen((disposition) {
        if (!mounted) return;

        if (message.playbackDuration == null || disposition.duration != null) {
          message.playbackDuration = disposition.duration;
        }

        message.positionNotifier.value = disposition.position.inMilliseconds.toDouble();
        message.playbackPosition = disposition.position;
      });

      setState(() {
        message.updatePlaybackState(playing: true);
        _currentlyPlayingAudio = message;
      });

    } catch (e) {
      debugPrint('Playback error: $e');
      _resetPlayback(message);
    }
  }

  void _resetPlayback(ConversationModel message) {
    if (!mounted) return;
    message.updatePlaybackState(playing: false, position: Duration.zero);
  }

  Future<void> _stopPlaying(ConversationModel message) async {
    try {
      await _audioPlayer.stopPlayer();
      await _playbackSubscription?.cancel();
      if (mounted) {
        message.updatePlaybackState(playing: false, position: Duration.zero);
        _currentlyPlayingAudio = null;
      }
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> _seekAudio(ConversationModel message, Duration position) async {
    await _audioPlayer.seekToPlayer(position);
    message.positionNotifier.value = position.inMilliseconds.toDouble();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }



  Future<void> _loadBackgroundSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      bgColor =
      _prefs?.getString('bg_color_${widget.lastMessageModel.userId}') != null
          ? Color(int.parse(
          _prefs!.getString('bg_color_${widget.lastMessageModel.userId}')!))
          : null;
      bgImage = _prefs?.getString('bg_image_${widget.lastMessageModel.userId}');
    });
  }

  Future<void> _loadMuteStatus() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted =
          _prefs?.getBool('mute_${widget.lastMessageModel.docId}') ?? false;
    });
  }

  void _updateTypingStatus() {
    if (_textController.text.isNotEmpty) {
      _cubit.updateTyping(true);
    } else {
      _cubit.updateTyping(false);
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 200.0 &&
        _cubit.hasMessages && _isLoadingOldMessages) {
      _isLoadingOldMessages = false;
      _cubit.getOldMessages(docId: widget.lastMessageModel.docId).then((_) {
        _isLoadingOldMessages = true;
      });
    }
    setState(() {
      beginFromEnd = _scrollController.position.maxScrollExtent > 0;
    });
  }

  Future<void> _sendTextMessage() async {
    if (_textController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          text: _textController.text,
          content: 'text',
          dateTime: DateTime.now(),
        ),
      );
      setState(() => _textController.clear());
    } catch (e) {
      print('Error sending text message: $e');
      showToast(msg: 'Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendAudioMessage({
    required Duration duration
}) async {
    if (_audioPath == null) return;

    setState(() => _isSending = true);

    try {
      File audioFile = File(_audioPath!);
      final url = _audioPath;  await checkFile(audioFile);

      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          content: 'audio',
          url: url,
          dateTime: DateTime.now(),
          playbackDuration: duration,
          playbackPosition: Duration.zero,
        ),
      );
      _audioPath = null;
    } catch (e) {
      print('Error sending audio message: $e');
      showToast(msg: 'Failed to send audio message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendMediaMessage({
    required MediaType type,
    required File file,
    String? url,
    String? text,
    VideoPlayerController? videoController,
  }) async {
    setState(() => _isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          content: type.name,
          url: url,
          type: type,
          file: file,
          dateTime: DateTime.now(),
          videoController: videoController,
          text: text,
        ),
      );
    } catch (e) {
      print('Error sending media message: $e');
      showToast(msg: 'Failed to send media message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }


  Future<void> _pickImage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        Navigator.pop(context);

        navigator(
            context: context,
            link: PublishingConfirmationScreen(
                file: File(pickedFile.path),
                buildEmojiPicker: _buildEmojiPicker(),
                onTap: (text) async {
                  _sendMediaMessage(
                      type: MediaType.image,
                      text: text ?? '',
                      file: imageFile,
                      url: await checkFile(imageFile) ?? ''
                  ).whenComplete(()=> Navigator.pop(context));
                }
            )
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error picking image: $e');
      showToast(msg: 'Failed to pick image');
    }
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pickedFile = await ImagePicker().pickVideo(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);
        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();

        Navigator.pop(context);

        navigator(
            context: context,
            link: PublishingConfirmationScreen(
                file: videoFile,
                buildEmojiPicker: _buildEmojiPicker(),
                videoController: controller,
                onTap: (text) async {
                  _sendMediaMessage(
                    type: MediaType.video,
                    text: text ?? '',
                    file: videoFile,
                    url: await checkFile(videoFile) ?? '',
                    videoController: controller,
                  ).whenComplete(()=> Navigator.pop(context));
                }
            )
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error picking video: $e');
      showToast(msg: 'Failed to pick video');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera);
      if (pickedFile == null) return;
      final url = ''; //await checkFile(videoFile);

      await _sendMediaMessage(
          type: MediaType.image,
          file: File(pickedFile.path),
          url: url ?? ''
      );
    } catch (e) {
      print('Error taking photo: $e');
      showToast(msg: 'Failed to take photo');
    }
  }

  void _toggleMessageSelection(ConversationModel message, bool isLongPress) {
    setState(() {
      if (isLongPress) {
        _clearSelection();
        message.isActive = true;
        _selectedMessageIds.add(message.messageId ?? '');
        selectedItems = 1;
      } else {
        if (selectedItems > 0) {
          message.isActive = !message.isActive;
          if (message.isActive) {
            _selectedMessageIds.add(message.messageId ?? '');
            selectedItems += 1;
          } else {
            _selectedMessageIds.remove(message.messageId ?? '');
            selectedItems -= 1;
          }
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _cubit.conversationsList
          .expand((group) => group.messages)
          .forEach((e) => e.isActive = false);
      _selectedMessageIds.clear();
      selectedItems = 0;
    });
  }

  void _removeSelectedMessages() {
    if (_selectedMessageIds.isEmpty) return;

    _cubit.deleteMessage(
        messagesIds: _selectedMessageIds,
        docId: widget.lastMessageModel.docId
    );
    _clearSelection();
  }

  Future<void> _toggleMute(bool mute) async {
    setState(() => _isMuted = mute);
    await _prefs?.setBool('mute_${widget.lastMessageModel.docId}', mute);

    if (mute) {
      await _notificationService.unsubscribeFromTopic(
          'chat_${widget.lastMessageModel.docId}');
      showToast(msg: 'تم كتم إشعارات هذه المحادثة');
    } else {
      await _notificationService.subscribeToTopic(
          'chat_${widget.lastMessageModel.docId}');
      showToast(msg: 'تم تفعيل إشعارات هذه المحادثة');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      ConversationsCubit()
        ..getConversations(docId: widget.lastMessageModel.docId)
        ..getUserOnlineStatus(
            widget.onlineStatusService, widget.lastMessageModel.userId!)
        ..getUserLastSeen(
            widget.onlineStatusService, widget.lastMessageModel.userId!)
        ..getUserTypingStatus(
            widget.onlineStatusService, widget.lastMessageModel.userId!)
        ..updateUnreadMessages(widget.lastMessageModel.docId),
      child: BlocConsumer<ConversationsCubit, CubitStates>(
        listener: (context, state) {},
        builder: (context, state) {
          _cubit = ConversationsCubit.get(context);
          widget.lastMessageModel.isOnline =
              _cubit.isOnline ?? widget.lastMessageModel.isOnline;
          widget.lastMessageModel.isTyping =
              _cubit.isTyping ?? widget.lastMessageModel.isTyping;
          widget.lastMessageModel.lastSeen =
              _cubit.lastSeen ?? widget.lastMessageModel.lastSeen;
          if (bgColor == null && bgImage == null) {
            _loadBackgroundSettings();
          }

          return Scaffold(
            appBar: _buildAppBar(context),
            body: Container(
              decoration: _buildBackgroundDecoration(bgColor, bgImage),
              child: Column(
                children: [
                  const Divider(height: 1),
                  Expanded(child: _buildMessagesList()),
                  if (_showEmojiPicker) _buildEmojiPicker(),
                  const Divider(height: 1),
                  _buildInputArea(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () =>
        selectedItems > 0 ? _clearSelection() : Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      title: selectedItems > 0
          ? Text('$selectedItems')
          : InkWell(
        onTap: () =>
            navigator(
                context: context,
                link: EditPersonalAccount(
                    userId: widget.lastMessageModel.userId!)
            ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(widget.lastMessageModel.userImage!),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lastMessageModel.userName!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.lastMessageModel.isOnline == true
                        ? widget.lastMessageModel.isTyping == true
                        ? 'Typing...'
                        : 'Online'
                        : _formatLastSeen(widget.lastMessageModel.lastSeen!),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (selectedItems < 1) ...[
          IconButton(
            icon: const Icon(Icons.videocam_outlined, size: 25.0),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.local_phone_outlined, size: 25.0),
            onPressed: () {},
          ),
          PopupMenuButton(
            itemBuilder: (context) =>
            [
              const PopupMenuItem(
                value: 'info',
                child: Text('Conversation Information'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Conversation'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _showChatInfo(context);
                  break;
                case 'clear':
                  _showClearChatDialog(context);
                  break;
              }
            },
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _removeSelectedMessages,
          ),
      ],
    );
  }

  Widget _buildMessagesList() {
    final conversations = _cubit.conversationsList;

    return ListView.builder(
      controller: _scrollController,
      reverse: beginFromEnd,
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final group = conversations[index];
        return Column(
          children: [
            _buildDateHeader(group.title, context),
            ...group.messages.map((message) =>
                _buildMessageItem(message, context)),
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
          color: Theme
              .of(context)
              .brightness == Brightness.light
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
      onTap: () => _toggleMessageSelection(message, false),
      onLongPress: () => _toggleMessageSelection(message, true),
      child: Container(
        color: message.isActive ? Colors.blue.shade400 : Colors.transparent,
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
          onTap: () => _showFullImage(url, context),
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
            child: Image.network(url,
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
      onTap: () => _showFullVideo(message, context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          message.url!.isNotEmpty
              ? Container(
            decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade700 : Colors.grey,
                borderRadius: BorderRadius.circular(8)),
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
                  Icons.play_arrow, size: 50, color: Colors.white),
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

  Widget _buildInputArea(BuildContext context) {
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
            child: buildInputField(
              context: context,
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
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _showMediaPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takePhoto,
          ),
          _isSending
              ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          )
              : GestureDetector(
            onTap: _textController.text.isNotEmpty ? _sendTextMessage : null,
            onLongPress: _toggleRecording,
            onLongPressUp: _toggleRecording,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: _micIsActive ? Colors.red : null,
              ),
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                _textController.text.isNotEmpty ? Icons.send : Icons.mic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _textController.text = _textController.text + emoji.emoji;
        },
        config: const Config(),
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
              formatTime(message.dateTime ?? DateTime.now()),
              style: TextStyle(
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 12,
              ),
            ),
            if (message.senderId == UserDetails.userId) ...[
              const SizedBox(width: 4),
              Icon(
                  widget.lastMessageModel.isOnline == true
                      ? Icons.done_all
                      : Icons.check,
                  size: 16
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showMediaPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) =>
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('صورة من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('فيديو من المعرض'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showChatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Conversation Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.lastMessageModel.userImage!),
                  ),
                  title: Text(widget.lastMessageModel.userName!),
                  subtitle: Text(
                      _isMuted
                          ? 'Notifications are muted'
                          : 'Notifications are active'),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: !_isMuted,
                    onChanged: (value) => _toggleMute(!value),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.wallpaper),
                  title: const Text('Conversation Background'),
                  onTap: () => _showBackgroundOptions(context),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('تم'),
              ),
            ],
          ),
    );
  }

  void _showBackgroundOptions(BuildContext context) {
    Navigator.pop(context); // Close previous dialog

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Conversation background'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Choose a color'),
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Choose an image'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBackgroundImage();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery);
      if (pickedFile != null) {
        await _prefs?.setString(
            'bg_image_${widget.lastMessageModel.userId}',
            pickedFile.path
        );
        await _prefs?.remove('bg_color_${widget.lastMessageModel.userId}');
        if (mounted) {
          setState(() {
            bgImage = pickedFile.path;
            bgColor = null;
          });
        }
        showToast(msg: 'The conversation background has been changed');
      }
    } catch (e) {
      print('Error picking background image: $e');
      showToast(msg: 'Failed to set background image');
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Choose a background color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                color: bgColor ?? Colors.transparent,
                onColorChanged: (color) async {
                  await _prefs?.setString(
                      'bg_color_${widget.lastMessageModel.userId}',
                      color.value.toString()
                  );
                  await _prefs?.remove(
                      'bg_image_${widget.lastMessageModel.userId}');
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {
                      bgColor = color;
                      bgImage = null;
                    });
                  }
                },
              ),
            ),
          ),
    );
  }

  BoxDecoration? _buildBackgroundDecoration(Color? bgColor, String? bgImage) {
    if (bgImage != null && File(bgImage).existsSync()) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(bgImage)),
          fit: BoxFit.cover,
        ),
      );
    } else if (bgColor != null) {
      return BoxDecoration(color: bgColor);
    }
    return null;
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Clear conversation'),
            content: const Text(
                'Are you sure you want to clear your conversation history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _cubit.deleteConversation(
                        docId: widget.lastMessageModel.docId);
                    showToast(
                        msg: 'The conversation has been successfully deleted');
                  } catch (e) {
                    showToast(
                        msg: 'Failed to clear conversation: ${e.toString()}');
                  }
                },
                child: const Text('clear', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showFullImage(String? imageFile, BuildContext context) {
    if (imageFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          Dialog(
            child: InteractiveViewer(
              child: Image.network(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
    );
  }

  void _showFullVideo(ConversationModel message, BuildContext context) async {
    if (message.file == null) return;

    _fullScreenVideoController = VideoPlayerController.network(message.url!);
    await _fullScreenVideoController!.initialize();
    _fullScreenVideoController!.play();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _fullScreenVideoController!.addListener(() {
              setState(() {});
            });

            return WillPopScope(
              onWillPop: () async {
                await _fullScreenVideoController!.pause();
                await _fullScreenVideoController!.dispose();
                _fullScreenVideoController = null;
                return true;
              },
              child: Dialog(
                backgroundColor: Colors.black,
                insetPadding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: _fullScreenVideoController!.value
                          .aspectRatio,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_fullScreenVideoController!.value.isPlaying) {
                              _fullScreenVideoController!.pause();
                            } else {
                              _fullScreenVideoController!.play();
                            }
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_fullScreenVideoController!),

                            if (!_fullScreenVideoController!.value.isPlaying)
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
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            _fullScreenVideoController!,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            colors: const VideoProgressColors(
                              playedColor: Colors.blue,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.grey,
                            ),
                          ),

                          _buildVideoTimeIndicator(
                            position: _fullScreenVideoController!.value
                                .position,
                            duration: _fullScreenVideoController!.value
                                .duration,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoTimeIndicator({
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        Text(
          '$totalMinutes:$totalSeconds',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
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
                    await _stopPlaying(message);
                  } else {
                    await _playRecording(message);
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
                            onChangeStart: (_) => _playbackSubscription?.pause(),
                            onChanged: (value) {
                              message.positionNotifier.value = value;
                            },
                            onChangeEnd: (value) async {
                              await _seekAudio(message, Duration(milliseconds: value.toInt()));
                              if (message.isPlaying) _playbackSubscription?.resume();
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

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) return 'now';
    if (difference.inMinutes < 60) {
      return 'last seen ${difference.inMinutes} minute';
    }
    if (difference.inHours < 24) return 'last seen ${difference.inHours} hour';
    return 'last seen ${difference.inDays} day';
  }
}