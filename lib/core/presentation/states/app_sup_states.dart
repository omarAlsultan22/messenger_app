import 'base/main_app_sup_state.dart';
import 'base/main_app_sub_state.dart';
import 'base/main_loaded_state.dart';
import 'loaded_states.dart';


abstract class DoubleModelAppState<T, U> extends MainAppSupState {
  final T? firstModel;
  final U? secondModel;

  DoubleModelAppState({
    required super.subState,
    required this.firstModel,
    required this.secondModel,
  });

  @override
  LoadedState get dataModels =>
      DoubleModelSuccessState(
          firstModel: firstModel,
          secondModel: secondModel
      );

  DoubleModelAppState copyWith({
    T? firstModel,
    U? secondModel,
    MainAppSubState? subState
  });
}


abstract class TripleModelAppState<T, U, S> extends MainAppSupState {
  final T? firstModel;
  final U? secondModel;
  final S? thirdModel;

  TripleModelAppState({
    required super.subState,
    required this.firstModel,
    required this.secondModel,
    required this.thirdModel,
  });

  @override
  LoadedState get dataModels =>
      TripleModelSuccessState(
          firstModel: firstModel,
          secondModel: secondModel,
          thirdModel: thirdModel
      );

  TripleModelAppState copyWith({
    T? firstModel,
    U? secondModel,
    S? thirdModel,
    MainAppSubState? subState
  });
}


