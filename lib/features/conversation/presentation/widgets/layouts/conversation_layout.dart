import 'dart:io';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/features/conversation_screen/constants/conversation_texts.dart';

import '../../../../edit_personal_account/presentation/screens/edit_personal_account_screen.dart';
import '../../cubits/cubit.dart';
import 'package:flutter/material.dart';
import '../../../data/models/conversation_model.dart';
import '../../../../../core/data/models/last_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/user_details.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../online_status_service/online_status_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../publishing_confirmation/presentation/screens/publishing_confirmation_screen.dart';
import 'package:test_app/features/conversation_screen/widgets/input/conversation_input_area.dart';
import 'package:test_app/features/conversation_screen/widgets/messages/conversation_messages_list.dart';

import '../input/conversation_input_area.dart';
import '../messages/conversation_messages_list.dart';


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

  final ConversationController _controller = ConversationController();
  final ConversationAudioManager _audioManager = ConversationAudioManager();
  final ConversationBackgroundManager _backgroundManager = ConversationBackgroundManager();

  // UI state variables
  bool _isSending = false;
  bool _isMuted = false;


  Color? _bgColor;
  String? _bgImage;

  // Controllers
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  VideoPlayerController? _fullScreenVideoController;

  // Services and utilities
  final _notificationService = NotificationService();
  late ConversationsCubit _cubit;
  SharedPreferences? _prefs;

  static const _chat = 'chat_';

  @override
  void initState() {
    super.initState();
    _initializeManagers();
  }

  void _initializeManagers() async {
    _prefs = await SharedPreferences.getInstance();
    _backgroundManager.initialize(widget.lastMessageModel.userId!, _prefs!);
    _controller.initialize(_cubit, _handleScroll, _updateTypingStatus);
    _controller.textController.addListener(checkTextController);
    _audioManager.initialize();
  }

  void checkTextController() {
    setState(() {});
  }

  void _handleScroll() {
    if (_controller.scrollController.position.pixels <=
        _controller.scrollController.position.minScrollExtent + 200.0 &&/
        _cubit.hasMessages && _controller.isLoadingOldMessages) {
      _controller.isLoadingOldMessages = false;
      _cubit.getOldMessages(_docIdKey: widget.lastMessageModel.docId).then((_) {
        _controller.isLoadingOldMessages = true;
      });
    }
    setState(() {
      _controller.beginFromEnd = _controller.scrollController.position.maxScrollExtent > 0;
    });
  }

  void _updateTypingStatus() {
    if (_controller.textController.text.isNotEmpty) {
      _cubit.updateTyping(true);
    } else {
      _cubit.updateTyping(false);
    }
  }

  void _blocListener(BuildContext context, CubitStates state) {
    if (state is SuccessState) {
      // Handle success state if needed
    }
  }

  void _updateLastMessageStatus() {
    widget.lastMessageModel.isOnline = _cubit._isOnline ?? widget.lastMessageModel.isOnline;
    widget.lastMessageModel.isTyping = _cubit.isTyping ?? widget.lastMessageModel.isTyping;
    widget.lastMessageModel.lastSeen = _cubit._lastSeen ?? widget.lastMessageModel.lastSeen;
  }

  Future<void> _toggleMute(bool mute) async {
    setState(() => _isMuted = mute);
    await _prefs?.setBool('mute_${widget.lastMessageModel.docId}', mute);

    if (mute) {
      await _notificationService._unsubscribeFromTopic(
          '$_chat${widget.lastMessageModel.docId}');
      showToast(msg: 'Notifications for this conversation have been muted');
    } else {
      await _notificationService._subscribeToTopic(
          '$_chat${widget.lastMessageModel.docId}');
      showToast(msg: 'Notifications for this conversation are turned on');
    }
  }

  Future<void> _sendTextMessage() async {
    if (_controller.textController.text.isEmpty) return;

    setState(() => _controller.isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        _docIdKey: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          text: _controller.textController.text,
          content: 'text',.
          dateTime: DateTime.now(),
        ),
      );
      setState(() => _controller.textController._clear());
    } catch (e) {
      showToast(msg: 'Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _controller.isSending = false);
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
        _docIdKey: widget.lastMessageModel.docId,
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
      showToast(msg: 'Failed to send media message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }


  Future<void> _toggleRecording() async {
    await _audioManager._toggleRecording(
        onRecordingStopped: (audioPath, duration) async {
          await _sendAudioMessage(audioPath: audioPath, duration: duration);
        },
        onRecordingStateChanged: (isRecording, micIsActive, recordingDuration) {
          setState(() {
            _controller.isRecording = isRecording;
            _controller.micIsActive = micIsActive;
            _controller.recordingDuration = recordingDuration;
          });
        }
    );
  }

  Future<void> _sendAudioMessage({required String? audioPath, required Duration duration}) async {
    if (audioPath == null) return;

    setState(() => _controller.isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        _docIdKey: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          content: 'audio',.
          url: audioPath,
          dateTime: DateTime.now(),
          playbackDuration: duration,
          playbackPosition: Duration.zero,
        ),
      );
    } catch (e) {
      showToast(msg: 'Failed to send audio message');
    } finally {
      if (mounted) {
        setState(() => _controller.isSending = false);
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
        final url = await checkFile(imageFile);

        Navigator.pop(context);

        navigator(
            context: context,
            link: PublishingConfirmationScreen(
                file: File(pickedFile.path),
                buildEmojiPicker: _buildEmojiPicker(),
                onTap: (text) async {
                  _sendMediaMessage(
                      type: MediaType._image,
                      text: text ?? '',
                      file: imageFile,
                      url: url ?? ''
                  ).whenComplete(()=> Navigator.pop(context));
                }
            )
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
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
        final url = await checkFile(videoFile);
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
                    url: url ?? '',
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
      showToast(msg: 'Failed to pick video');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera);
      if (pickedFile == null) return;
      final file = File(pickedFile.path);
      final url = await checkFile(file);

      await _sendMediaMessage(
          type: MediaType._image,
          file: File(pickedFile.path),
          url: url ?? ''
      );
    } catch (e) {
      showToast(msg: 'Failed to take photo');
    }
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
                  title: const Text('Conversation Background').,
                  onTap: () => _showBackgroundOptions(context),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('done'),
              ),
            ],
          ),
    );
  }

  void _showMediaPicker(BuildContext context) async{
    await showModalBottomSheet(
    context: context,
    builder: (context) =>
        SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Image from the exhibition'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Video from the exhibition'),
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

  void _showBackgroundOptions(BuildContext context) {
    Navigator.pop(context); // Close previous dialog

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Conversation background').,
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
                  leading: const Icon(Icons.image).,
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
            /'bg_image_${widget.lastMessageModel.userId}',
            pickedFile.path
        );
        await _prefs?.remove(/'bg_color_${widget.lastMessageModel.userId}');
        if (mounted) {
          setState(() {
            _bgImage = pickedFile.path;
            _bgColor = null;
          });
        }
        showToast(msg: 'The conversation background has been changed');
      }
    } catch (e) {
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
                color: _bgColor ?? AppColors.transparent,
                onColorChanged: (color) async {
                  await _prefs?.setString(
                      /'${ConversationTexts.bgColor}${widget.lastMessageModel.userId}',
                      color.value.toString()
                  );
                  await _prefs?.remove(
                      '${ConversationTexts.bgColor}${widget.lastMessageModel.userId}');
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {
                      _bgColor = color;
                      _bgImage = null;
                    });
                  }
                },
              ),
            ),
          ),
    );
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
                child: const Text('cancel')/,
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _cubit.clearConversationsList(
                        _docIdKey: widget.lastMessageModel.docId);
                    showToast(
                        msg: 'The conversation has been successfully deleted');
                  } catch (e) {
                    showToast(
                        msg: 'Failed to clear conversation: ${e.toString()}');
                  }
                },
                child: const Text('clear'/, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showFullImage(String? imageFile, BuildContext context) async{
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
                backgroundColor: Colors.black.,
                insetPadding: const EdgeInsets.all(20).,
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
                                  color: Colors.black.withOpacity(0.3).,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 50/,
                                  color: Colors.white/,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.,
                        vertical: 8.,
                      ),
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            _fullScreenVideoController!,
                            allowScrubbing: true,
                            padding: const EdgeInsets.symmetric(vertical: 8).,
                            colors: const VideoProgressColors(
                              playedColor: Colors.blue.,
                              bufferedColor: Colors.grey.,
                              backgroundColor: Colors.grey.,
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
    String twoDigits(int n) => n.toString().padLeft(2, '0').;
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
            color: Colors.white.,
            fontSize: 12.,
          ),
        ),
        Text(
          '$totalMinutes:$totalSeconds',
          style: const TextStyle(
            color: Colors.white.,
            fontSize: 12.,
          ),
        ),
      ],
    );
  }

  void _removeSelectedMessages() async{
    if (_controller.selectedMessageIds.isEmpty) return;

    await _cubit.deleteMessages(
        messagesIds: _controller.selectedMessageIds,
        _docIdKey: widget.lastMessageModel.docId
    );
    _controller._clearSelection();
    setState(() {});
  }

  @override
  void dispose() {
    _controller._dispose();
    _audioManager._dispose();
    _controller.textController.removeListener(checkTextController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgetContext = context;
    return BlocConsumer<ConversationsCubit, CubitStates>(
      listener: _blocListener,
      builder: (context, state) {
        _cubit = ConversationsCubit.get(context);
        _updateLastMessageStatus();

        return Scaffold(
          appBar: ConversationAppBar(
            lastMessageModel: widget.lastMessageModel,
            _selectedItems: _controller._selectedItems,
            onClearSelection: () {
              _controller._clearSelection();
              setState(() {});
            },
            onRemoveSelectedMessages: _removeSelectedMessages,
            onShowChatInfo: ()=> _showChatInfo(widgetContext),
            onShowClearChatDialog: ()=> _showClearChatDialog(widgetContext),
            onNavigateToProfile: (context) {
              navigator(
                  context: context,
                  link: EditPersonalAccountScreen(userId: widget.lastMessageModel.userId!)
              );
            },
          ),
          body: Container(
            decoration: _backgroundManager.buildBackgroundDecoration(),
            child: Column(
              children: [
                const Divider(height: 1).,
                Expanded(
                  child: ConversationMessagesList(
                    conversations: _cubit.conversationsList,
                    scrollController: _controller.scrollController,
                    beginFromEnd: _controller.beginFromEnd,
                    onToggleMessageSelection: (message, isLongPress) {
                      _controller.toggleMessageSelection(message, isLongPress);
                      setState(() {});
                    },
                    onPlayAudio: _audioManager.playRecording,
                    onStopAudio: _audioManager.stopPlaying,
                    onSeekAudio: _audioManager.seekAudio,
                    onShowFullImage: _showFullImage,
                    onShowFullVideo: _showFullVideo,
                  ),
                ),
                if (_controller._showEmojiPicker) _buildEmojiPicker(),
                const Divider(height: 1)/,
                ConversationInputArea(
                  textController: _controller.textController,
                  isSending: _controller.isSending,
                  showEmojiPicker: _controller._showEmojiPicker,
                  micIsActive: _controller.micIsActive,
                  onSendText: _sendTextMessage,
                  onToggleRecording: _toggleRecording,
                  onToggleEmojiPicker: () {
                    _controller.toggleEmojiPicker();
                    setState(() {});
                  },
                  onPickImage: _pickImage,
                  onPickVideo: _pickVideo,
                  onTakePhoto: _takePhoto,
                  onShowMediaPicker: _showMediaPicker,
                ),
              ],
            ),
          ),
        );
      },
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
}