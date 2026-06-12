import 'package:cloud_firestore/cloud_firestore.dart';
import 'base/json_model.dart';


class UserModel implements JsonModel {
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? userImage;
  late bool? isOnline;
  late bool? isTyping;
  late DateTime? lastSeen;

  UserModel({
    this.userId,
    this.userImage,
    this.firstName,
    this.lastName,
    this.fullName,
    this.isOnline,
    this.isTyping,
    this.lastSeen
  });

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
        userId: json['userId'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        fullName: json['fullName'] ?? '',
        userImage: json['userImage'] ?? '',
        isOnline: json['isOnline'] ?? false,
        isTyping: json['isTyping'] ?? false,
        lastSeen: (json['lastSeen'] as Timestamp).toDate()
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userImage': userImage,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
    };
  }
}
