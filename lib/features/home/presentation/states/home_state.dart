import '../../../../core/data/models/last_message_model.dart';
import '../../../../core/errors/exceptions/base/app_exception.dart';
import 'package:test_app/core/presentation/states/app_sub_states.dart';
import '../../../../core/presentation/states/base/main_app_sub_state.dart';
import 'package:test_app/features/home/data/models/home_Success_state.dart';
import 'package:test_app/core/presentation/states/base/main_app_sup_state.dart';


class HomeState extends MainAppSupState {
  final String profileImage;
  final List<LastMessageModel> friendList;
  const HomeState({
    required super.subState,
    required this.friendList,
    required this.profileImage,
  });

  factory HomeState.initial(){
    return HomeState(
      friendList: [],
      profileImage: '',
      subState: InitialState(),
    );
  }

  bool get isEmpty => friendList.isEmpty;

  HomeState copyWith({
    String? profileImage,
    MainAppSubState? subState,
    List<LastMessageModel>? friendList,
  }) {
    return HomeState(
      subState: subState ?? this.subState,
      friendList: friendList ?? this.friendList,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  HomeSuccessState get dataModels =>
      HomeSuccessState(
          friendList: friendList,
          profileImage: profileImage
      );

  @override
  R when<R>({
    required R Function() onInitial,
    required R Function() onLoading,
    required R Function(HomeSuccessState) onLoaded,
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