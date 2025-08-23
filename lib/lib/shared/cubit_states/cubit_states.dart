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
class InitialState<T> extends CubitStates<T>{
  InitialState() : super();
}
class LoadingState<T> extends CubitStates<T>{
  LoadingState({super.stateKey});
}
class SuccessState<T> extends CubitStates<T>{
  SuccessState({super.message, super.stateKey});
}
class ErrorState<T> extends CubitStates<T>{
  ErrorState({super.error, super.stateKey});
}

class UnreadCountUpdatedState<T> extends CubitStates<T>{
  UnreadCountUpdatedState() : super();
}
class UserStatusUpdatedState<T> extends CubitStates<T>{
  UserStatusUpdatedState() : super();
}
class PhoneCodeSentState<T> extends CubitStates<T>{
  PhoneCodeSentState() : super();
}

