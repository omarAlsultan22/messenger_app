import 'dart:io';
import '../../enums/media_type.dart';
import 'package:flutter/material.dart';
import '../../../data/models/data_model.dart';
import '../app_bar/conversation_app_bar.dart';
import '../input/conversation_input_area.dart';
import '../../../data/models/user_status.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants/conversation_texts.dart';
import '../controllers/conversation_controller.dart';
import '../messages/conversation_messages_list.dart';
import '../../../data/models/conversation_model.dart';
import '../controllers/conversation_audio_manager.dart';
import 'package:test_app/core/constants/app_sizes.dart';
import 'package:test_app/core/constants/app_colors.dart';
import 'package:test_app/core/constants/app_strings.dart';
import 'package:test_app/core/utils/format_duration.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:test_app/core/constants/app_paddings.dart';
import '../controllers/conversation_background_manager.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/services/online_status_service.dart';
import '../../../../../core/data/models/last_message_model.dart';
import 'package:test_app/core/services/media_upload_service.dart';
import 'package:test_app/features/conversation/utils/show_toast.dart';
import 'package:test_app/core/presentation/widgets/navigation/navigator.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../../../edit_personal_account/presentation/screens/edit_personal_account_screen.dart';
import '../../../../publishing_confirmation/presentation/screens/publishing_confirmation_screen.dart';


class ConversationLayout extends StatefulWidget {
  final Function({
  required String docId,
  required String userId,
  required ConversationModel conversation
  }) sendMessage;
  final Function(bool) updateTyping;
  final Function(List<String>) deleteMessages;
  final Future <void> getOldMessages;
  final VoidCallback clearConversationsList;

  final DataModel dataModel;
  final UserStatus userStatus;
  final CacheHelper cacheHelper;
  final LastMessageModel lastMessageModel;
  final OnlineStatusService onlineStatusService;

  const ConversationLayout({
    super.key,
    required this.dataModel,
    required this.userStatus,
    required this.cacheHelper,
    required this.sendMessage,
    required this.updateTyping,
    required this.getOldMessages,
    required this.deleteMessages,
    required this.lastMessageModel,
    required this.onlineStatusService,
    required this.clearConversationsList
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
  VideoPlayerController? _fullScreenVideoController;

  // Services and utilities
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeManagers();
  }

  void _initializeManagers() async {
    _backgroundManager.initialize(
        widget.lastMessageModel.userId!, widget.cacheHelper);
    _controller.initialize(
        handleScroll: _handleScroll,
        updateTyping: _updateTypingStatus,
        conversationList: widget.dataModel.conversationList
    );
    _controller.addListener(checkTextController);
    _audioManager.initialize();
  }

  void checkTextController() {
    setState(() {});
  }

  void _handleScroll() {
    if (_controller.pixels <=
        _controller.minScrollExtent + 200.0 &&
        widget.dataModel.hasMessages && _controller.isLoadingOldMessages) {
      _controller.isLoadingOldMessages = false;
      widget.getOldMessages.then((_) {
        _controller.isLoadingOldMessages = true;
      });
    }
    setState(() {
      _controller.beginFromEnd =
          _controller.maxScrollExtent > 0;
    });
  }

  void _updateTypingStatus() {
    if (_controller.isNotEmpty) {
      widget.updateTyping(true);
    } else {
      widget.updateTyping(false);
    }
  }

  void _updateLastMessageStatus() {
    widget.lastMessageModel.isOnline =
        widget.userStatus.isOnline ?? widget.lastMessageModel.isOnline;
    widget.lastMessageModel.isTyping =
        widget.userStatus.isTyping ?? widget.lastMessageModel.isTyping;
    widget.lastMessageModel.lastSeen =
        widget.userStatus.lastSeen ?? widget.lastMessageModel.lastSeen;
  }

  Future<void> _toggleMute(bool mute) async {
    setState(() => _isMuted = mute);
    await widget.cacheHelper.setBool(
        key: 'mute_${widget.lastMessageModel.docId}', value: mute);

    if (mute) {
      await _notificationService.unsubscribeFromTopic(
          'chat_${widget.lastMessageModel.docId}');
      ShowToast.show(
          msg: 'Notifications for this conversation have been muted');
    } else {
      await _notificationService.subscribeToTopic(
          'chat_${widget.lastMessageModel.docId}');
      ShowToast.show(msg: 'Notifications for this conversation are turned on');
    }
  }

  Future<void> _sendTextMessage() async {
    if (!_controller.isNotEmpty) return;

    setState(() => _controller.isSending = true);

    try {
      await widget.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: AppStrings.docId,
          text: _controller.message,
          content: 'text',
          dateTime: DateTime.now(),
        ),
      );
      setState(() => _controller.clear);
    } catch (e) {
      ShowToast.show(msg: 'Failed to send message');
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
      await widget.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: AppStrings.docId,
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
      ShowToast.show(msg: 'Failed to send media message');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }


  Future<void> _toggleRecording() async {
    await _audioManager.toggleRecording(
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

  Future<void> _sendAudioMessage(
      {required String? audioPath, required Duration duration}) async {
    if (audioPath == null) return;

    setState(() => _controller.isSending = true);

    try {
      await widget.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: AppStrings.docId,
          content: 'audio',
          url: audioPath,
          dateTime: DateTime.now(),
          playbackDuration: duration,
          playbackPosition: Duration.zero,
        ),
      );
    } catch (e) {
      ShowToast.show(msg: 'Failed to send audio message');
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
      final imageFile = await MediaUploadService.pickImage();
      if (imageFile != null) {
        final url = await MediaUploadService.checkAndUploadFile(imageFile);

        Navigator.pop(context);

        BuildNavigator.build(
            context: context,
            link: PublishingConfirmationScreen(
                file: imageFile,
                buildEmojiPicker: _buildEmojiPicker(),
                onTap: (text) async {
                  _sendMediaMessage(
                      type: MediaType.image,
                      text: text ?? '',
                      file: imageFile,
                      url: url ?? ''
                  ).whenComplete(() => Navigator.pop(context));
                }
            )
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ShowToast.show(msg: 'Failed to pick image');
    }
  }

  Future<void> _pickVideo() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final videoFile = await MediaUploadService.pickImage();
      if (videoFile != null) {
        final url = await MediaUploadService.checkAndUploadFile(videoFile);
        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();

        Navigator.pop(context);

        BuildNavigator.build(
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
                  ).whenComplete(() => Navigator.pop(context));
                }
            )
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ShowToast.show(msg: 'Failed to pick video');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final imageFile = await MediaUploadService.pickImage();
      if (imageFile == null) return;
      final url = await MediaUploadService.checkAndUploadFile(imageFile);

      await _sendMediaMessage(
          type: MediaType.image,
          file: imageFile,
          url: url ?? ''
      );
    } catch (e) {
      ShowToast.show(msg: 'Failed to take photo');
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
                  title: Text(widget.lastMessageModel.fullName!),
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
                child: const Text('done'),
              ),
            ],
          ),
    );
  }

  void _showMediaPicker(BuildContext context) async {
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
        await widget.cacheHelper.setString(
            key: '${ConversationTexts.bgImage}${widget.lastMessageModel
                .userId}',
            value: pickedFile.path
        );
        await widget.cacheHelper.removeValue(
            key: '${ConversationTexts.bgColor}${widget.lastMessageModel
                .userId}');
        if (mounted) {
          setState(() {
            _bgImage = pickedFile.path;
            _bgColor = null;
          });
        }
        ShowToast.show(msg: 'The conversation background has been changed');
      }
    } catch (e) {
      ShowToast.show(msg: 'Failed to set background image');
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
                  await widget.cacheHelper.setString(
                      key: '${ConversationTexts.bgColor}${widget
                          .lastMessageModel.userId}',
                      value: color.value.toString()
                  );
                  await widget.cacheHelper.removeValue(
                      key: '${ConversationTexts.bgColor}${widget
                          .lastMessageModel.userId}');
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
                child: const Text('cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    widget.clearConversationsList();
                    ShowToast.show(
                        msg: 'The conversation has been successfully deleted');
                  } catch (e) {
                    ShowToast.show(
                        msg: 'Failed to clear conversation: ${e.toString()}');
                  }
                },
                child: const Text('clear',
                    style: TextStyle(color: AppColors.redPrimaryValue)),
              ),
            ],
          ),
    );
  }

  void _showFullImage(String? imageFile, BuildContext context) async {
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
                backgroundColor: AppColors.black,
                insetPadding: AppPaddings.large,
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
                                  color: AppColors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                  color: AppColors.white,
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
                              playedColor: AppColors.bluePrimaryValue,
                              bufferedColor: AppColors.greyPrimaryValue,
                              backgroundColor: AppColors.greyPrimaryValue,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FormatDuration.getDuration(position),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: AppSizes.xs,
          ),
        ),
        Text(
          FormatDuration.getDuration(duration),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: AppSizes.xs,
          ),
        ),
      ],
    );
  }

  void _removeSelectedMessages() async {
    if (_controller.selectedMessageIdsIsEmpty) return;

    widget.deleteMessages(_controller.selectedMessageIds);
    _controller.clearSelection();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioManager.dispose();
    _controller.removeListener(checkTextController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateLastMessageStatus();

    return Scaffold(
      appBar: ConversationAppBar(
        lastMessageModel: widget.lastMessageModel,
        selectedItems: _controller.selectedItems,
        onClearSelection: () {
          _controller.clearSelection();
          setState(() {});
        },
        onRemoveSelectedMessages: _removeSelectedMessages,
        onShowChatInfo: () => _showChatInfo(context),
        onShowClearChatDialog: () => _showClearChatDialog(context),
        onNavigateToProfile: (context) {
          BuildNavigator.build(
              context: context,
              link: EditPersonalAccountScreen(
                  docId: widget.lastMessageModel.userId!)
          );
        },
      ),
      body: Container(
        decoration: _backgroundManager.buildBackgroundDecoration(),
        child: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: ConversationMessagesList(
                lastMessageModel: widget.lastMessageModel,
                conversations: widget.dataModel.conversationList,
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
            if (_controller.showEmojiPicker) _buildEmojiPicker(),
            const Divider(height: 1),
            ConversationInputArea(
              textController: _controller.textController,
              isSending: _controller.isSending,
              showEmojiPicker: _controller.showEmojiPicker,
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