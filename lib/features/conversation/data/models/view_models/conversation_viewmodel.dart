import 'package:flutter/foundation.dart';

import '../conversation_model.dart';

// نقل الـ AudioPlayerState و ProcessingState هنا لأنهم خاصين بالمنطق
class AudioPlayerState {
  final bool playing;
  final ProcessingState processingState;
  AudioPlayerState(this.playing, this.processingState);
}

enum ProcessingState {
  idle,
  loading,
  buffering,
  ready,
  completed
}

class ConversationViewModel extends ChangeNotifier {
  List<ConversationModel> _messages = [];
  List<ConversationModel> get messages => _messages;

  // الـ ValueNotifiers تنتقل هنا
  final ValueNotifier<AudioPlayerState> playerStateNotifier;
  final ValueNotifier<double> positionNotifier = ValueNotifier(0.0);
  late final ValueNotifier<bool> isPlayingNotifier;

  // معرف الرسالة النشطة حالياً
  String? _activeMessageId;

  ConversationViewModel() :
        playerStateNotifier = ValueNotifier(AudioPlayerState(false, ProcessingState.idle)) {
    isPlayingNotifier = ValueNotifier(false);
  }

  void addMessage(ConversationModel message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  // ✅ دالة updatePlaybackState منقولة هنا
  void updatePlaybackState({
    required String messageId,
    Duration? position,
    Duration? duration,
    bool? playing,
  }) {
    // تحديث الـ Model المحدد
    final index = _messages.indexWhere((msg) => msg.messageId == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        playbackPosition: position ?? _messages[index].playbackPosition,
        playbackDuration: duration ?? _messages[index].playbackDuration,
        isPlaying: playing ?? _messages[index].isPlaying,
      );
    }

    // تحديث الـ ValueNotifiers (للـ UI)
    if (_activeMessageId == messageId) {
      positionNotifier.value = position?.inMilliseconds.toDouble() ?? 0;
      isPlayingNotifier.value = playing ?? isPlayingNotifier.value;

      playerStateNotifier.value = AudioPlayerState(
        playing ?? false,
        playing == true ? ProcessingState.ready : ProcessingState.idle,
      );
    }

    notifyListeners();
  }

  // ✅ دالة dispose منقولة هنا
  void disposeResources() {
    positionNotifier.dispose();
    isPlayingNotifier.dispose();
    playerStateNotifier.dispose();
  }

  @override
  void dispose() {
    disposeResources();
    super.dispose();
  }

  // دالة مساعدة لتعيين الرسالة النشطة
  void setActiveMessage(String messageId) {
    _activeMessageId = messageId;
    notifyListeners();
  }
}