import 'base/main_loaded_state.dart';


class SingleModelSuccessState<T> extends LoadedState<T, Never> {
  SingleModelSuccessState({required super.firstModel});
}


class MultiModelSuccessState<T, U> extends LoadedState<T, U> {
  MultiModelSuccessState({required super.firstModel, super.secondModel});
}




