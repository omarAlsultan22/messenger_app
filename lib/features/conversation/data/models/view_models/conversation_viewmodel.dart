import 'package:flutter/foundation.dart';
import '../conversation_model.dart';


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

  final ValueNotifier<AudioPlayerState> playerStateNotifier;
  final ValueNotifier<double> positionNotifier = ValueNotifier(0.0);
  late final ValueNotifier<bool> isPlayingNotifier;

  String? _activeMessageId;

  ConversationViewModel() :
        playerStateNotifier = ValueNotifier(AudioPlayerState(false, ProcessingState.idle)) {
    isPlayingNotifier = ValueNotifier(false);
  }

  void addMessage(ConversationModel message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  void updatePlaybackState({
    required String messageId,
    Duration? position,
    Duration? duration,
    bool? playing,
  }) {
    final index = _messages.indexWhere((msg) => msg.messageId == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(
        playbackPosition: position ?? _messages[index].playbackPosition,
        playbackDuration: duration ?? _messages[index].playbackDuration,
        isPlaying: playing ?? _messages[index].isPlaying,
      );
    }

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

  void setActiveMessage(String messageId) {
    _activeMessageId = messageId;
    notifyListeners();
  }
}