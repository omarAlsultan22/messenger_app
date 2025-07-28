import 'package:test_app/lib/models/user_model.dart';

class PostModel extends UserModel {
  late String? userText;
  late String? userState;
  late String? docId;
  late String? userPost;
  final bool isViewed;
  final DateTime? viewedAt;
  late String? postType;
  late String? pathType;
  final DateTime? dateTime;
  int? likesNumber;
  int? commentsNumber;
  int? sharesNumber;


  PostModel({
    super.userId,
    super.userName,
    super.userImage,
    this.postType,
    this.pathType,
    this.isViewed = false,
    this.viewedAt,
    this.sharesNumber,
    this.likesNumber,
    this.commentsNumber,
    this.userState,
    this.docId,
    this.dateTime,
    this.userPost,
    this.userText,
  });


  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'docId': docId,
      'postType': postType,
      'userText': userText,
      'userPost': userPost,
      'dateTime': dateTime,
      'sharesNumber': sharesNumber,
      'userState': userState,
      'isViewed': isViewed ? 1 : 0,
      'viewedAt': viewedAt?.millisecondsSinceEpoch,
    };
  }
}