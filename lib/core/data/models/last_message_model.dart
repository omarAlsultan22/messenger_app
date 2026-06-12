import 'base/json_model.dart';
import 'package:test_app/core/data/models/user_model.dart';


class LastMessageModel extends UserModel implements JsonModel {
  final String docId;
  final bool isFriend;
  final String lastMessage;
  final int unreadMessagesCount;
  final String lastMessageSender;
  final List<String> participants;
  final DateTime lastMessageDateTime;

  LastMessageModel({
    super.userId,
    super.firstName,
    super.userImage,
    super.isOnline,
    super.isTyping,
    super.lastSeen,
    this.isFriend = true,
    required this.docId,
    required this.lastMessage,
    required this.participants,
    required this.lastMessageSender,
    required this.lastMessageDateTime,
    required this.unreadMessagesCount,
  });

  bool get isEmpty => docId.isEmpty;

  LastMessageModel copyWith({
    String? docId,
    String? userId,
    bool? isOnline,
    bool? isTyping,
    bool? isFriend,
    String? userName,
    String? userImage,
    DateTime? lastSeen,
    String? lastMessage,
    int? unreadMessagesCount,
    String? lastMessageSender,
    List<String>? participants,
    DateTime? lastMessageDateTime,
  }) {
    return LastMessageModel(
        docId: docId ?? this.docId,
        userId: userId ?? this.userId,
        isTyping: isTyping ?? isTyping,
        lastSeen: lastSeen ?? this.lastSeen,
        isOnline: isOnline ?? this.isOnline,
        firstName: userName ?? this.firstName,
        userImage: userImage ?? this.userImage,
        lastMessage: lastMessage ?? this.lastMessage,
        participants: participants ?? this.participants,
        lastMessageSender: lastMessageSender ?? this.lastMessageSender,
        lastMessageDateTime: lastMessageDateTime ?? this.lastMessageDateTime,
        unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount
    );
  }

  factory LastMessageModel.fromJson(Map<String, dynamic> json){
    return LastMessageModel(
        docId: json['docId'] ?? '',
        userId: json['userId'] ?? '',
        firstName: json['userName'] ?? '',
        userImage: json['userImage'] ?? '',
        participants: json['participants'] ?? '',
        lastMessage: json['lastMessage'] ?? '',
        isOnline: json['isOnline'] ?? false,
        isTyping: json['isTyping'] ?? false,
        lastSeen: json['lastSeen'] ?? DateTime.now(),
        lastMessageSender: json['lastMessageSender'] ?? '',
        lastMessageDateTime: json['lastMessageDateTime'] ?? '',
        unreadMessagesCount: json['unreadMessagesCount'] ?? 0
    );
  }

  static LastMessageModel createEmptyLastMessage(String friendId) {
    return LastMessageModel(
      docId: '',
      participants: [],
      lastMessage: '',
      lastMessageSender: '',
      userId: friendId,
      firstName: '',
      userImage: '',
      isOnline: false,
      lastSeen: DateTime.now(),
      unreadMessagesCount: 0,
      lastMessageDateTime: DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'lastMessage': lastMessage,
      'participants': participants,
      'lastMessageSender': lastMessageSender,
      'lastMessageDateTime': lastMessageDateTime,
      'unreadMessagesCount': unreadMessagesCount
    };
  }
}
