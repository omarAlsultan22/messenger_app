import 'main_app_sub_state.dart';
import 'main_loaded_state.dart';
import '../../../errors/exceptions/app_exception.dart';


abstract class MainAppSupState<T, U> extends LoadedState<T, U>{
  final bool isConnected;
  final MainAppSubState? subState;

  MainAppSupState({
    this.subState,
    super.firstModel,
    super.secondModel,
    this.isConnected = true
  });

  MainAppSupState updateState({
    T? firstModel,
    U? secondModel,
    bool? isConnected,
    MainAppSubState? subState
  });

  R when<R>({
    R Function()? onConnection,
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  });
}