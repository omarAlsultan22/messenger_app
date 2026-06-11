import 'dart:async';
import '../../../data/services/audio_recorder.dart';
import '../../../data/models/conversation_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';


class ConversationAudioManager {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  ConversationModel? _currentlyPlayingAudio;
  StreamSubscription<PlaybackDisposition>? _playbackSubscription;

  Timer? _recordingTimer;
  bool _isRecording = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;

  static const _timeDuration = Duration(milliseconds: 100);

  Future<void> initialize() async {
    await _audioRecorder.init();
    await _audioPlayer.openPlayer();
  }

  Future<void> dispose() async {
    await _stopAllPlaybacks();
    _playbackSubscription?.cancel();
    _recordingTimer?.cancel();
    await _audioRecorder.dispose();
    await _audioPlayer.closePlayer();
  }

  Future<void> toggleRecording({
    required Function(String?, Duration) onRecordingStopped,
    required Function(bool, bool, Duration) onRecordingStateChanged,
  }) async {
    if (_isRecording) {
      _audioPath = await _audioRecorder.stopRecording();
      _recordingTimer?.cancel();

      final durationToSend = _recordingDuration;

      onRecordingStateChanged(false, false, Duration.zero);
      _isRecording = false;
      _recordingDuration = Duration.zero;

      await onRecordingStopped(_audioPath, durationToSend);
    } else {
      _recordingDuration = Duration.zero;
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        onRecordingStateChanged(false, true, Duration.zero);
      }
      await _audioRecorder.startRecording();

      _recordingTimer = Timer.periodic(_timeDuration, (timer) {
        _recordingDuration += _timeDuration;
        onRecordingStateChanged(true, true, _recordingDuration);
      });

      onRecordingStateChanged(true, true, Duration.zero);
      _isRecording = true;
    }
  }

  Future<void> _stopAllPlaybacks() async {
    await _audioPlayer.stopPlayer();
    await _playbackSubscription?.cancel();

    _currentlyPlayingAudio?.updatePlaybackState(
        playing: false, position: Duration.zero);
    _currentlyPlayingAudio = null;
  }

  Future<void> playRecording(ConversationModel message) async {
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
        if (message.playbackDuration == null || disposition.duration != null) {
          message.playbackDuration = disposition.duration;
        }

        message.positionNotifier.value =
            disposition.position.inMilliseconds.toDouble();
        message.playbackPosition = disposition.position;
      });

      message.updatePlaybackState(playing: true);
      _currentlyPlayingAudio = message;
    } catch (e) {
      print('Playback error: $e');
      _resetPlayback(message);
    }
  }

  void _resetPlayback(ConversationModel message) {
    message.updatePlaybackState(playing: false, position: Duration.zero);
  }

  Future<void> stopPlaying(ConversationModel message) async {
    try {
      await _audioPlayer.stopPlayer();
      await _playbackSubscription?.cancel();
      message.updatePlaybackState(playing: false, position: Duration.zero);
      _currentlyPlayingAudio = null;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> seekAudio(ConversationModel message, Duration position) async {
    await _audioPlayer.seekToPlayer(position);
    message.positionNotifier.value = position.inMilliseconds.toDouble();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}