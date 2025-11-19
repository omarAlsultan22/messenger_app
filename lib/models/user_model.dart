import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_model.dart';


class UserModel implements MapModel {
  final String? userId;
  final String? userName;
  final String? userImage;
  final String? userPhone;
  late bool? isOnline;
  late bool? isTyping;
  late DateTime? lastSeen;

  UserModel({
    this.userId,
    this.userName,
    this.userImage,
    this.userPhone,
    this.isOnline,
    this.isTyping,
    this.lastSeen
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
        userId: json['userId'] ?? '',
        userName: json['fullName'] ?? '',
        userImage: json['userImage'] ?? '',
        isOnline: json['isOnline'] ?? false,
        isTyping: json['isTyping'] ?? false,
        lastSeen: (json['lastSeen'] as Timestamp).toDate()
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'userImage': userImage,
      'userName': userName,
      'userPhone': userPhone,
    };
  }
}
