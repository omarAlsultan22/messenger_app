import '../../../../core/data/models/last_message_model.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import 'package:test_app/core/presentation/states/app_sup_states.dart';
import '../../../../core/presentation/states/base/main_loaded_state.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';


class HomeState extends DoubleModelAppState<String, List<LastMessageModel>> {
  HomeState({
    super.subState,
    super.firstModel,
    super.secondModel,
  });

  factory HomeState.initial(){
    return HomeState(
      firstModel: '',
      secondModel: [],
      subState: InitialState(),
    );
  }

  bool get isEmpty => secondModel!.isEmpty;

  @override
  HomeState copyWith({
    String? firstModel,
    List<LastMessageModel>? secondModel,
    MainAppSubState? subState
  }) {
    return HomeState(
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