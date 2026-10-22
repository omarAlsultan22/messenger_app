import 'package:test_app/features/home/presentation/widgets/layouts/home_layout.dart';
import '../../../../core/presentation/widgets/states/initial_state.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import '../../../../core/services/domain/i_online_status_service.dart';
import '../../../../core/services/domain/i_notification_service.dart';
import 'package:test_app/core/services/data/session_service.dart';
import '../../../../core/domain/data_sources/cache_helper.dart';
import '../../../../core/di/service _locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../states/home_state.dart';
import '../cubits/home_cubit.dart';


class HomeScreen extends StatelessWidget {
  final SessionService sessionService;
  HomeScreen({super.key, required this.sessionService});

  static const _defaultInfoText = 'Friends';
  static const _defaultInfoIcon = Icons.menu;

  late final _currentUid = sessionService.currentUid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<HomeCubit>()
          ..getProfileImage(docId: _currentUid)
          ..getFriends(docId: _currentUid),
        child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = HomeCubit.get(context);
              return state.when(
                onInitial: () =>
                const InitialStateWidget(
                    text: _defaultInfoText, icon: _defaultInfoIcon),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) =>
                  HomeLayout(
                    friendList: data.friendList,
                    sessionService: sessionService,
                    profileImage: data.profileImage,
                    cacheHelper: sl<CacheHelper>(),
                    onlineStatusService: sl<IOnlineStatusService>(),
                    notificationService: sl<INotificationService>(),
                  ),
                onError: (error) =>
                    error.buildErrorWidget(
                        onRetry: () =>
                        cubit
                          ..getProfileImage(docId: _currentUid)
                          ..getFriends(docId: _currentUid)
                    ),
              );
            }
        )
    );
  }
}