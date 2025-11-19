import 'dart:io';
import 'map_model.dart';
import 'package:flutter/cupertino.dart';
import '../shared/constants/media_type.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';


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


class ConversationModel implements MapModel{
  final MediaType? type;
  final String? text;
  late String? senderId;
  late String? messageId;
  final String? content;
  String? url;
  final DateTime? dateTime;
  bool isPlaying;
  bool isSeen;
  final FlutterSoundPlayer? audioPlayer;
  bool isActive;
  Duration? playbackPosition;
  Duration? playbackDuration;
  File? file;
  bool unreadMessage;
  VideoPlayerController? videoController;
  final ValueNotifier<AudioPlayerState> playerStateNotifier;
  final ValueNotifier<double> positionNotifier = ValueNotifier(0.0);
  late final ValueNotifier<bool> isPlayingNotifier;

  ConversationModel({
    this.type,
    this.senderId,
    this.messageId,
    this.content,
    this.url,
    this.dateTime,
    this.isPlaying = false,
    this.isSeen = false,
    this.audioPlayer,
    this.isActive = false,
    this.playbackPosition,
    this.playbackDuration,
    this.file,
    this.unreadMessage = true,
    this.videoController,
    this.text,
  }): playerStateNotifier = ValueNotifier(AudioPlayerState(false, ProcessingState.idle)),
        isPlayingNotifier = ValueNotifier(isPlaying);

  factory ConversationModel.fromJson({
    required Map<String, dynamic> json
  }){
    return ConversationModel(
        senderId: json['senderId'] ?? '',
        messageId: json['docId'] ?? '',
        content: json['content'] ?? '',
        text: json['text'] ?? '',
        url: json['url'] ?? '',
        dateTime: (json['dateTime'] as Timestamp?)?.toDate(),
        isSeen: json['isSeen'] ?? false
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'docId': messageId,
      'content': content,
      'text': text,
      'url': url,
      'dateTime': dateTime,
      'isSeen': isSeen,
      'unreadMessage': unreadMessage
    };
  }

  void updatePlaybackState({
    Duration? position,
    Duration? duration,
    bool? playing,
  }) {
    playbackPosition = position ?? playbackPosition;
    playbackDuration = duration ?? playbackDuration;
    isPlaying = playing ?? isPlaying;

    positionNotifier.value = playbackPosition?.inMilliseconds.toDouble() ?? 0;
    isPlayingNotifier.value = isPlaying;
  }

  void dispose() {
    positionNotifier.dispose();
    isPlayingNotifier.dispose();
  }
}
