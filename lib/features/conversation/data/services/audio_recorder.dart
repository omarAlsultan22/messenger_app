import 'dart:async';
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


