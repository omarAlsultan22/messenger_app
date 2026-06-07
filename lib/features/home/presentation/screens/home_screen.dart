import 'package:test_app/features/home/data/repositories_impl/firestore_home_repository.dart';
import 'package:test_app/features/home/presentation/widgets/layouts/home_layout.dart';
import 'package:test_app/features/home/data/data_source/firestore_home_service.dart';
import 'package:test_app/features/home/domain/useCases/get_profile_use_case.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:test_app/core/presentation/states/loaded_states.dart';
import 'package:test_app/core/constants/app_strings.dart';
import '../../domain/useCases/get_friends_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../states/home_state.dart';
import '../cubits/home_cubit.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _defaultInfoText = 'Friends';
  static const _defaultInfoIcon = Icons.menu;

  @override
  Widget build(BuildContext context) {
    final service = FirestoreHomeService();
    final firestoreHomeRepository = FirestoreHomeRepository(service: service);
    final getProfileUseCase = GetProfileUseCase(
        repository: firestoreHomeRepository);
    final getFriendsUseCase = GetFriendsUseCase(
        repository: firestoreHomeRepository);
    return BlocProvider(
        create: (context) =>
        HomeCubit(
            getProfileUseCase: getProfileUseCase,
            getFriendsUseCase: getFriendsUseCase)
          ..getProfileImage(docId: AppStrings.docId)
          ..getFriends(docId: AppStrings.docId),
        child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = HomeCubit.get(context);
              return state.when(
                onInitial: () =>
                const InitialStateWidget(
                    text: _defaultInfoText, icon: _defaultInfoIcon),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (loadedState) {
                  if (loadedState is DoubleModelSuccessState) {
                    HomeLayout(profileImage: loadedState.firstModel,
                        cacheHelper: cacheHelper,
                        friendList: loadedState.secondModel);
                  }
                  return const InitialStateWidget(
                      text: _defaultInfoText, icon: _defaultInfoIcon);
                },
                onError: (error) =>
                    error.buildErrorWidget(
                        onRetry: () =>
                        cubit
                          ..getProfileImage(docId: AppStrings.docId)
                          ..getFriends(docId: AppStrings.docId)
                    ),
              );
            }
        )
    );
  }
}