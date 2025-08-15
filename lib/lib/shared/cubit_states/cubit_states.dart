abstract class CubitStates<T>{
  final T? message;
  final String? key;
  final String? error;
  CubitStates({this.message, this.key, this.error});
}
class InitialState extends CubitStates{}
class LoadingState extends CubitStates{
  LoadingState({super.key});
}
class SuccessState extends CubitStates{
  SuccessState({super.message, super.key});
}
class ErrorState extends CubitStates{
  ErrorState({super.error, super.key});
}

class UnreadCountUpdatedState extends CubitStates{}
class UserStatusUpdatedState extends CubitStates{}
class PhoneCodeSentState extends CubitStates {}

