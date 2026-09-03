import 'account_model.dart';
import '../../../../core/data/models/message_result_model.dart';
import 'package:test_app/core/presentation/states/base/main_loaded_state.dart';


class EditPersonalAccountSuccessState extends LoadedState {
  final AccountModel accountModel;
  final MessageResult messageResult;

  EditPersonalAccountSuccessState({
    required this.accountModel,
    required this.messageResult,
  });
}