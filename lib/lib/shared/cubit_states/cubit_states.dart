abstract class CubitStates{}
class InitialState extends CubitStates{}
class LoadingState extends CubitStates{}
class SuccessState<T> extends CubitStates{
  final T? message;
  SuccessState({this.message});
}
class ErrorState extends CubitStates{
  final String error;
  ErrorState(this.error);
}

class UnreadCountUpdatedState extends CubitStates{}
class UserStatusUpdatedState extends CubitStates{}
class PhoneCodeSentState extends CubitStates {}

