import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

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

enum MediaType { image, video, file, text, audio }

class ConversationModel {
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

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'docId': messageId,
      'content': content,
      'text': text,
      'url': url,
      'dateTime': dateTime,
      'isSeen': isSeen
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

class ConversationData {
  final List <ConversationModel> conversationsList;

  ConversationData({
    required this.conversationsList
  });

  factory ConversationData.fromJson(QuerySnapshot querySnapshot){
    List<ConversationModel> conversationData = [];

    for (final doc in querySnapshot.docs) {
      final json = doc.data() as Map<String, dynamic>;
      final conversationModel = ConversationModel.fromJson(json: json);
      conversationData.add(conversationModel);
    }

    return ConversationData(conversationsList: conversationData);
  }
}
Map<String, List<ConversationModel>> groupMessagesByDate(
    List<ConversationModel> messages) {

  final Map<String, List<ConversationModel>> groupedMessages = {};

  for (final message in messages) {
    final messageDate = DateTime(
        message.dateTime!.year,
        message.dateTime!.month,
        message.dateTime!.day
    );

    String header = date(messageDate: messageDate);

    groupedMessages.putIfAbsent(header, () => []).add(message);
  }

  return groupedMessages;
}

String date({
  required DateTime messageDate,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  String header;

  if (messageDate == today) {
    header = 'Today';
  } else if (messageDate == yesterday) {
    header = 'Yesterday';
  } else if (now
      .difference(messageDate)
      .inDays < 7) {
    header = 'Last week';
  } else {
    header = DateFormat('MMMM yyyy').format(messageDate); // "March 2023"
  }
  return header;
}