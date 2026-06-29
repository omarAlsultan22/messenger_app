import 'dart:io';
import 'audio_player_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import '../../presentation/enums/media_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../presentation/enums/processing_state.dart';
import '../../../../core/data/models/base/json_model.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';


class ConversationModel implements JsonModel{
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
        messageId: json['messageId'] ?? '',
        content: json['content'] ?? '',
        text: json['text'] ?? '',
        url: json['url'] ?? '',
        dateTime: (json['dateTime'] as Timestamp?)?.toDate(),
        isSeen: json['isSeen'] ?? false
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'messageId': messageId,
      'content': content,
      'text': text,
      'url': url,
      'dateTime': dateTime,
      'isSeen': isSeen,
      'unreadMessage': unreadMessage
    };
  }

  ConversationModel copyWith({
    bool? isPlaying,
    Duration? playbackPosition,
    Duration? playbackDuration,
  }) {
    return ConversationModel(
      senderId: senderId,
      messageId: messageId,
      content: content,
      text: text,
      url: url,
      dateTime: dateTime,
      isSeen: isSeen,
      unreadMessage: unreadMessage,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      playbackDuration: playbackDuration ?? this.playbackDuration,
    );
  }

  void updatePlaybackState({
    required bool playing,
    Duration position = Duration.zero,
  }) {
    isPlaying = playing;
    isPlayingNotifier.value = playing;
    playbackPosition = position;
    positionNotifier.value = position.inMilliseconds.toDouble();
    playerStateNotifier.value = AudioPlayerState(
      playing,
      playing ? ProcessingState.playing : ProcessingState.idle,
    );
  }
}

extension ExactMatchesExtension on List<ConversationModel> {
  List<ConversationModel> exactMatches(bool Function(ConversationModel) test) {
    return where(test).toList();
  }
}

