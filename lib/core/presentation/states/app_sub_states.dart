import '../../errors/exceptions/base/app_exception.dart';
import 'base/main_app_sub_state.dart';


class InitialState extends MainAppSubState{
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onInitial();
  }
}


class LoadingState extends MainAppSubState{
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onLoading();
  }
}


class SuccessState extends MainAppSubState {
  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError,
  }) {
    return onLoaded();
  }
}


class ErrorState extends MainAppSubState {
  final AppException error;

  ErrorState({
    required this.error,
  });

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function() onLoaded,
    required R Function(AppException) onError
  }) {
    return onError(error);
  }
}