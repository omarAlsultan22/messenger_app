import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import '../../../../core/presentation/states/base/main_app_sup_state.dart';
import '../../../../core/presentation/states/loaded_states.dart';


class SettingsState extends MainAppSupState<UserModel, MessageResult> {
  SettingsState({
    super.subState,
    super.firstModel,
    super.secondModel,
    super.isConnected
  });

  UserModel? get userModel => firstModel;

  LoadedState get dataModels =>
      MultiModelSuccessState<UserModel, MessageResult>(
          firstModel: firstModel,
          secondModel: secondModel
      );

  @override
  SettingsState updateState({
    UserModel? firstModel,
    MessageResult? secondModel,
    bool? isConnected,
    MainAppSubState? subState
  }) {
    return SettingsState(
        subState: subState ?? this.subState,
        firstModel: firstModel ?? this.firstModel,
        secondModel: secondModel ?? this.secondModel,
        isConnected: isConnected ?? this.isConnected
    );
  }

  @override
  R when<R>({
    R Function()? onConnection,
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    if (onConnection != null && !isConnected &&
        firstModel == null
    ) {
      return onConnection();
    }
    return subState!.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(dataModels),
        onError: (failure) => onError.call(failure));
  }
}