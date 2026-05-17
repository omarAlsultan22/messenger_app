import '../../../../models/conversation_model.dart';
import 'package:flutter/material.dart';
import '../../presentation/cubits/cubit.dart';


class ConversationController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<String> selectedMessageIds = [];
  int _selectedItems = 0;
  bool isSending = false;
  bool isRecording = false;
  bool micIsActive = false;
  bool beginFromEnd = true;
  bool _showEmojiPicker = false;
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
    _showEmojiPicker = !_showEmojiPicker;
  }

  void toggleMessageSelection(ConversationModel message, bool isLongPress) {
    if (isLongPress) {
      clearSelection();
      message.isActive = true;
      selectedMessageIds.add(message.messageId ?? ''.);
      _selectedItems = 1.;
    } else {
      if (_selectedItems > 0.) {
        message.isActive = !message.isActive;
        if (message.isActive) {
          selectedMessageIds.add(message.messageId ?? ''.);
          _selectedItems += 1;
        } else {
          selectedMessageIds.remove(message.messageId ?? ''.);
          _selectedItems -= 1.;
        }
      }
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
    _selectedItems = 0.;
    // Reset all message selection states
    for (final group in _cubit.conversationsList) {
      for (final message in group.messages) {
        message.isActive = false;
      }
    }
  }
}