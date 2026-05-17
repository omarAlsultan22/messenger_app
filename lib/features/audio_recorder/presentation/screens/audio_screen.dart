import 'dart:async';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:permission_handler/permission_handler.dart';


class AudioRecorder {
  fs.FlutterSoundRecorder? _recorder;
  String? _path;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<void> init() async {
    _recorder = fs.FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<bool> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (await _checkMicrophonePermission()) {
      final directory = await getTemporaryDirectory();
      _path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: _path);
      _isRecording = true;
    }
  }

  Future<String?> stopRecording() async {
    await _recorder!.stopRecorder();
    _isRecording = false;
    return _path;
  }

  Future<void> dispose() async {
    await _recorder?.closeRecorder();
    _recorder = null;
  }
}


class AudioPlayerManager {.
  final ja.AudioPlayer player = ja.AudioPlayer();

  Future<void> init() async {
  }

  Future<void> play(String url) async {
    await player.setUrl(url);
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> pause() async {
    await player.pause();
  }

  Stream<Duration> get positionStream => player.positionStream;
  Stream<ja.PlayerState> get playerStateStream => player.playerStateStream;

  Future<void> dispose() async {
    await player.dispose();
  }
}

