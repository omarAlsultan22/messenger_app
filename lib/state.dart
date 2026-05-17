import '../../../../../core/presentation/states/base/main_app_sub_state.dart';
import '../../../../../core/presentation/states/base/main_app_sup_state.dart';
import '../../../../../core/presentation/states/base/main_loaded_state.dart';


class DataState extends MainAppSupState<QuestionsData, GameState> {
  final QuestionsKeys? key;

  DataState({
    this.key,
    super.subState,
    super.firstModel,
    super.secondModel,
    super.isConnected
  });

  bool get hasMore => firstModel!.hasMore;

  bool get listIsEmpty => firstModel!.listIsEmpty;

  List<QuestionModel> get questions => firstModel!.questions;

  DocumentSnapshot? get lastDocument => firstModel!.lastDocument;

  LoadedState get dataModels =>
      MultiModelSuccessState<QuestionsData, GameState>(
          firstModel: firstModel,
          secondModel: secondModel
      );

  QuestionsData copyWithQuestions({
    bool? hasMore,
    List<QuestionModel>? questions,
    DocumentSnapshot? lastDocument
  }) =>
      firstModel!.copyWith(
          hasMore: hasMore,
          questions: questions,
          lastDocument: lastDocument
      );

  GameState copyWithStart({
    int? points,
    int? currentIndex,
  }) =>
      secondModel!.copyWith(
          points: points,
          currentIndex: currentIndex
      );

  @override
  DataState updateState({
    QuestionsKeys? key,
    QuestionsData? firstModel,
    GameState? secondModel,
    bool? isConnected,
    MainAppSubState? subState
  }) =>
      DataState(
          key: key ?? this.key,
          subState: subState ?? this.subState,
          firstModel: firstModel ?? this.firstModel,
          secondModel: secondModel ?? this.secondModel,
          isConnected: isConnected ?? this.isConnected
      );

  @override
  R when<R>({
    R Function()? onConnection,
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(LoadedState) onLoaded,
    required R Function(AppException) onError
  }) {
    if (onConnection != null && !isConnected && listIsEmpty) {
      onConnection();
    }
    return subState!.when(
        onInitial: onInitial,
        onLoading: onLoading,
        onLoaded: () =>
            onLoaded.call(
                dataModels
            ),
        onError: (failure) => onError.call(failure));
  }
}