enum StatesKeys{
  backgroundColorAndImage,
  clearConversations,
  updateUnreadMessages,
  getConversation,
  deleteConversation,
  deleteMessage,
  sendMessage,
  getOldMessages,
  getAccount,
  updateAccount,
  getProfile,
  getFriends,
}

abstract class CubitStates<T>{
  final T? message;
  final StatesKeys? stateKey;
  final String? error;
  CubitStates({this.message, this.stateKey, this.error});
}
class InitialState extends CubitStates{}
class LoadingState extends CubitStates{
  LoadingState({super.stateKey});
}
class SuccessState extends CubitStates{
  SuccessState({super.message, super.stateKey});
}
class ErrorState extends CubitStates{
  ErrorState({super.error, super.stateKey});
}

class UnreadCountUpdatedState extends CubitStates{}
class UserStatusUpdatedState extends CubitStates{}
class PhoneCodeSentState extends CubitStates {}

