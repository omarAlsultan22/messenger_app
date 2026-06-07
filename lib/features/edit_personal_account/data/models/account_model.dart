class AccountModel {
  final String? userId;
  final String? userName;
  final String? userImage;
  final String? userState;

  AccountModel({
    this.userId,
    this.userName,
    this.userImage,
    this.userState
  });

  factory AccountModel.fromJson({
    required Map<String, dynamic> userInfo,
    required Map<String, dynamic> accountData}){
    return AccountModel(
      userId: accountData['userId'] ?? '',
      userName: accountData['fullName'] ?? '',
      userImage: accountData['userImage'] ?? '',
      userState: userInfo['userState'] ?? '',
    );
  }
}
