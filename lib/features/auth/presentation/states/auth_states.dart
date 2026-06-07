import '../../../../core/data/models/message_result_model.dart';


class AuthState {
  final MessageResult? messageResult;

  const AuthState({this.messageResult});

  factory AuthState.initial(){
    return AuthState(messageResult: MessageResult.initial());
  }
}