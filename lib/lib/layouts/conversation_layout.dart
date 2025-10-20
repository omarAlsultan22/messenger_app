import 'cubit.dart';
import 'package:flutter/material.dart';
import '../models/last_message_model.dart';
import 'app_bar/conversation_app_bar.dart';
import 'input/conversation_input_area.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'messages/conversation_messages_list.dart';
import 'controllers/conversation_controller.dart';
import 'controllers/conversation_audio_manager.dart';
import 'controllers/conversation_background_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/lib/shared/components/constants.dart';
import 'package:test_app/lib/shared/components/components.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import '../modules/online_status_service/online_status_service.dart';
import 'package:test_app/lib/modules/edit_personal_account/edit_personal_account_screen.dart';


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
  late ConversationsCubit _cubit;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
  }

  void _initializeManagers() async {
    _prefs = await SharedPreferences.getInstance();
    _backgroundManager.initialize(widget.lastMessageModel.userId!, _prefs!);
    _controller.initialize(_cubit, _handleScroll, _updateTypingStatus);
    _audioManager.initialize();
  }

  void _handleScroll() {
    if (_controller.scrollController.position.pixels <=
        _controller.scrollController.position.minScrollExtent + 200.0 &&
        _cubit.hasMessages && _controller.isLoadingOldMessages) {
      _controller.isLoadingOldMessages = false;
      _cubit.getOldMessages(docId: widget.lastMessageModel.docId).then((_) {
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
    widget.lastMessageModel.isOnline = _cubit.isOnline ?? widget.lastMessageModel.isOnline;
    widget.lastMessageModel.isTyping = _cubit.isTyping ?? widget.lastMessageModel.isTyping;
    widget.lastMessageModel.lastSeen = _cubit.lastSeen ?? widget.lastMessageModel.lastSeen;
  }

  Future<void> _sendTextMessage() async {
    if (_controller.textController.text.isEmpty) return;

    setState(() => _controller.isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          text: _controller.textController.text,
          content: 'text',
          dateTime: DateTime.now(),
        ),
      );
      setState(() => _controller.textController.clear());
    } catch (e) {
      print('Error sending text message: $e');
      showToast(msg: 'Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _controller.isSending = false);
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

  Future<void> _sendAudioMessage({required String? audioPath, required Duration duration}) async {
    if (audioPath == null) return;

    setState(() => _controller.isSending = true);

    try {
      await _cubit.sendMessage(
        userId: widget.lastMessageModel.userId!,
        docId: widget.lastMessageModel.docId,
        conversation: ConversationModel(
          senderId: UserDetails.userId,
          content: 'audio',
          url: audioPath,
          dateTime: DateTime.now(),
          playbackDuration: duration,
          playbackPosition: Duration.zero,
        ),
      );
    } catch (e) {
      print('Error sending audio message: $e');
      showToast(msg: 'Failed to send audio message');
    } finally {
      if (mounted) {
        setState(() => _controller.isSending = false);
      }
    }
  }

  Future<void> _pickImage() async {
    // Implementation for image picking
  }

  Future<void> _pickVideo() async {
    // Implementation for video picking
  }

  Future<void> _takePhoto() async {
    // Implementation for taking photo
  }

  void _showMediaPicker(BuildContext context) {
    // Implementation for media picker
  }

  void _showChatInfo(BuildContext context) {
    // Implementation for chat info
  }

  void _showClearChatDialog(BuildContext context) {
    // Implementation for clear chat dialog
  }

  void _showFullImage(String? imageFile, BuildContext context) {
    // Implementation for full image view
  }

  void _showFullVideo(ConversationModel message, BuildContext context) {
    // Implementation for full video view
  }

  void _removeSelectedMessages() {
    if (_controller.selectedMessageIds.isEmpty) return;

    _cubit.deleteMessage(
        messagesIds: _controller.selectedMessageIds,
        docId: widget.lastMessageModel.docId
    );
    _controller.clearSelection();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationsCubit, CubitStates>(
      listener: _blocListener,
      builder: (context, state) {
        _cubit = ConversationsCubit.get(context);
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
            onShowChatInfo: _showChatInfo,
            onShowClearChatDialog: _showClearChatDialog,
            onNavigateToProfile: (context) {
              navigator(
                  context: context,
                  link: EditPersonalAccount(userId: widget.lastMessageModel.userId!)
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
      },
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      height: 250,
      color: Colors.white,
      child: Center(
        child: Text('Emoji Picker - Implement with emoji_picker_flutter'),
      ),
    );
  }
}