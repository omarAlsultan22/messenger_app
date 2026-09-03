import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:test_app/core/presentation/states/base/main_app_sup_state.dart';
import 'package:test_app/features/edit_personal_account/data/models/account_model.dart';
import 'package:test_app/features/edit_personal_account/data/models/edit_personal_account_success_state.dart';


class EditPersonalAccountState extends MainAppSupState {
  final AccountModel accountModel;
  final MessageResult messageResult;

  const EditPersonalAccountState({
    required super.subState,
    required this.accountModel,
    required this.messageResult,
  });

  factory EditPersonalAccountState.initial(){
    return EditPersonalAccountState(
        subState: InitialState(),
        accountModel: AccountModel(),
        messageResult: MessageResult.initial()
    );
  }

  EditPersonalAccountState copyWith({
    MainAppSubState? subState,
    AccountModel? accountModel,
    MessageResult? messageResult
  }) {
    return EditPersonalAccountState(
      subState: subState ?? this.subState,
      accountModel: accountModel ?? this.accountModel,
      messageResult: messageResult ?? MessageResult.initial(),
    );
  }

  @override
  // TODO: implement dataModels
  EditPersonalAccountSuccessState get dataModels =>
      EditPersonalAccountSuccessState(
      accountModel: accountModel,
      messageResult: messageResult
  );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(EditPersonalAccountSuccessState) onLoaded,
    required R Function(AppException) onError
  }) {
    return subState!.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure));
  }
}