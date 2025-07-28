import 'package:test_app/lib/models/user_model.dart';

class LastMessageModel extends UserModel{
  final String docId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageDateTime;
  final String lastMessageSender;
  late int unreadMessagesCount;

  LastMessageModel({
    super.userId,
    super.userName,
    super.userImage,
    super.isOnline,
    super.isTyping,
    super.lastSeen,
    required this.docId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageDateTime,
    required this.lastMessageSender,
    required this.unreadMessagesCount,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json){
    return LastMessageModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'] ?? '',
      docId: json['docId'] ?? '',
      participants: json['participants'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageDateTime: json['lastMessageDateTime'] ?? '',
      lastMessageSender: json['lastMessageSender'] ?? '',
      isOnline: json['isOnline'] ?? false, isTyping: json['isTyping'] ?? false,
      lastSeen: json['lastSeen'] ?? DateTime.now(),
      unreadMessagesCount: json['unreadMessagesCount'] ?? 0
    );
  }

  static LastMessageModel createEmptyLastMessage(String friendId) {
    return LastMessageModel(
      docId: '',
      participants: [],
      lastMessage: '',
      lastMessageDateTime: DateTime.now(),
      lastMessageSender: '',
      userId: friendId,
      userName: '',
      userImage: '',
      isOnline: false,
      lastSeen: DateTime.now(),
      unreadMessagesCount: 0,
    );
  }

  @override
  Map<String, dynamic> toMap(){
    return {
      'docId': docId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageDateTime': lastMessageDateTime,
      'lastMessageSender': lastMessageSender,
      'unreadMessagesCount': unreadMessagesCount
    };
  }
}
String formatTime(DateTime timestamp) {
  final period = timestamp.hour < 12 ? 'AM' : 'PM';
  final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
  return '${hour.bitLength}:${timestamp.minute.toString().padLeft(2, '0')} $period';
}