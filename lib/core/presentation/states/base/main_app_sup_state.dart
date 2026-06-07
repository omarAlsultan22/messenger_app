import 'main_loaded_state.dart';
import 'main_app_sub_state.dart';
import '../../../errors/exceptions/base/app_exception.dart';


abstract class MainAppSupState{
  final MainAppSubState? subState;

  MainAppSupState({
    this.subState,
  });

  LoadedState get dataModels;

  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  });
}