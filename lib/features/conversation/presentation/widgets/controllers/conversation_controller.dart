import 'package:test_app/features/conversation/constants/conversation_texts.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_group.dart';
import 'package:flutter/material.dart';


class ConversationController {

  int selectedItems = 0;
  bool isSending = false;
  bool isRecording = false;
  bool micIsActive = false;
  bool beginFromEnd = true;
  bool showEmojiPicker = false;
  bool isLoadingOldMessages = true;
  List<String> selectedMessageIds = [];
  Duration recordingDuration = Duration.zero;

  late VoidCallback _handleScrollCallback;
  late VoidCallback _updateTypingCallback;

  static const _empty = ConversationTexts.empty;

  late List<MessageGroup> _conversationList;
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();

  void initialize({
    required VoidCallback handleScroll,
    required VoidCallback updateTyping,
    required List<MessageGroup> conversationList
  }) {
    _conversationList = conversationList;
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
      selectedMessageIds.add(message.messageId ?? _empty);
      selectedItems = 1;
    } else {
      if (selectedItems > 0) {
        message.isActive = !message.isActive;
        if (message.isActive) {
          selectedMessageIds.add(message.messageId ?? _empty);
          selectedItems += 1;
        } else {
          selectedMessageIds.remove(message.messageId ?? _empty);
          selectedItems -= 1;
        }
      }
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
    selectedItems = 0;
    // Reset all message selection states
    for (final group in _conversationList) {
      for (final message in group.messages) {
        message.isActive = false;
      }
    }
  }
}