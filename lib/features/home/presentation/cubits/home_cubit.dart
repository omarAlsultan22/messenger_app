import 'dart:async';
import '../states/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/useCases/get_friends_use_case.dart';
import '../../domain/useCases/get_profile_use_case.dart';
import '../../../../core/presentation/states/app_sub_states.dart';
import 'package:test_app/core/data/models/last_message_model.dart';
import '../../../../core/presentation/mixins/error_handler_mixin.dart';


class HomeCubit extends Cubit<HomeState> with ErrorHandlerMixin<HomeState>{
  final GetProfileUseCase _getProfileUseCase;
  final GetFriendsUseCase _getFriendsUseCase;

  HomeCubit({
    required GetProfileUseCase getProfileUseCase,
    required GetFriendsUseCase getFriendsUseCase,
  })
      : _getFriendsUseCase = getFriendsUseCase,
        _getProfileUseCase = getProfileUseCase,
        super(HomeState.initial());

  static HomeCubit get(context) => BlocProvider.of(context);

  StreamSubscription? _friendsSubscription;

  List<LastMessageModel>? get friendsList => state.secondModel;

  Future<void> getProfileImage({
    required String docId
  }) async {
    emit(state.copyWith(subState: LoadingState()));
    try {
      final profileImage = await _getProfileUseCase.execute(userId: docId);
      emit(state.copyWith(subState: SuccessState(), firstModel: profileImage));
    }
    catch (e, stackTrace) {
      handleError(e, stackTrace,
          onError: (failure) =>
              state.copyWith(
                  subState: ErrorState(
                      error: failure
                  )
              )
      );
    }
  }

  Future<void> getFriends({required String docId}) async {
    emit(state.copyWith(subState: LoadingState()));
    _friendsSubscription?.cancel();
    _friendsSubscription = _getFriendsUseCase.execute(userId: docId).listen(
            (updatedFriendsList) {
          if (updatedFriendsList.isEmpty && state.isEmpty) {
            state.copyWith(subState: InitialState());
          }
          emit(state.copyWith(
              subState: SuccessState(), secondModel: updatedFriendsList));
        },
        onError: (e) {
          handleError(e, StackTrace.current,
              onError: (failure) =>
                  state.copyWith(
                      subState: ErrorState(
                          error: failure
                      )
                  )
          );
        }
    );
  }

  @override
  Future<void> close() {
    _friendsSubscription?.cancel();
    return super.close();
  }
}