import 'package:test_app/features/home/presentation/widgets/layouts/home_layout.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:test_app/core/services/session_service.dart';
import '../../../../core/di/service _locator.dart';
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
    final sessionService = sl<SessionService>();
    final currentUid = sessionService.currentUid;

    return BlocProvider(
        create: (context) =>
        sl<HomeCubit>()
          ..getProfileImage(docId: currentUid)
          ..getFriends(docId: currentUid),
        child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = HomeCubit.get(context);
              return state.when(
                onInitial: () =>
                const InitialStateWidget(
                    text: _defaultInfoText, icon: _defaultInfoIcon),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) {
                  return HomeLayout(
                      cacheHelper: sl<CacheHelper>(),
                      profileImage: data.firstModel,
                      friendList: data.secondModel
                  );
                },
                onError: (error) =>
                    error.buildErrorWidget(
                        onRetry: () =>
                        cubit
                          ..getProfileImage(docId: currentUid)
                          ..getFriends(docId: currentUid)
                    ),
              );
            }
        )
    );
  }
}