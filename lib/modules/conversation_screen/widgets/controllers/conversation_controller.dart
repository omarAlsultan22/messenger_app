import '../../../../models/conversation_model.dart';
import 'package:flutter/material.dart';
import '../../cubit.dart';


class ConversationController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<String> selectedMessageIds = [];
  int selectedItems = 0;
  bool showEmojiPicker = false;
  bool isSending = false;
  bool isRecording = false;
  bool micIsActive = false;
  bool beginFromEnd = true;
  bool isLoadingOldMessages = true;
  Duration recordingDuration = Duration.zero;

  late ConversationsCubit _cubit;
  late VoidCallback _handleScrollCallback;
  late VoidCallback _updateTypingCallback;

  void initialize(ConversationsCubit cubit, VoidCallback handleScroll, VoidCallback updateTyping) {
    _cubit = cubit;
    _handleScrollCallback = handleScroll;
    _updateTypingCallback = updateTyping;

    scrollController.addListener(_handleScrollCallback);
    textController.addListener(_updateTypingCallback);
  }

  void dispose() {
    scrollController.removeListener(_handleScrollCallback);
    textController.removeListener(_updateTypingCallback);
    scrollController.dispose();
    textController.dispose();
  }


  void toggleEmojiPicker() {
    showEmojiPicker = !showEmojiPicker;
  }

  void toggleMessageSelection(ConversationModel message, bool isLongPress) {
    if (isLongPress) {
      clearSelection();
      message.isActive = true;
      selectedMessageIds.add(message.messageId ?? '');
      selectedItems = 1;
    } else {
      if (selectedItems > 0) {
        message.isActive = !message.isActive;
        if (message.isActive) {
          selectedMessageIds.add(message.messageId ?? '');
          selectedItems += 1;
        } else {
          selectedMessageIds.remove(message.messageId ?? '');
          selectedItems -= 1;
        }
      }
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
    selectedItems = 0;
    // Reset all message selection states
    for (final group in _cubit.conversationsList) {
      for (final message in group.messages) {
        message.isActive = false;
      }
    }
  }
}