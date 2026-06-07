import '../../../../core/data/models/message_result_model.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import 'package:test_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:test_app/features/edit_personal_account/data/models/account_model.dart';


class EditPersonalAccountState extends DoubleModelAppState<AccountModel, MessageResult> {
  EditPersonalAccountState({
    super.subState,
    super.firstModel,
    super.secondModel,
  });

  factory EditPersonalAccountState.initial(){
    return EditPersonalAccountState(
        firstModel: null,
        secondModel: MessageResult.initial(),
        subState: InitialState()
    );
  }

  @override
  EditPersonalAccountState copyWith({
    AccountModel? firstModel,
    MessageResult? secondModel,
    MainAppSubState? subState
  }) {
    return EditPersonalAccountState(
        subState: subState ?? this.subState,
        firstModel: firstModel ?? this.firstModel,
        secondModel: secondModel ?? this.secondModel,
    );
  }

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
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