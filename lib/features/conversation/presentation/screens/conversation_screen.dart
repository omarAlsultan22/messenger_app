import 'package:test_app/features/conversation/presentation/states/conversation_state.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import '../../../../core/services/online_status_service.dart';
import '../../../../core/data/models/last_message_model.dart';
import '../widgets/layouts/conversation_layout.dart';
import '../../data/models/conversation_model.dart';
import '../../../../core/di/service _locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/conversation_cubit.dart';
import 'package:flutter/material.dart';


class ConversationScreen extends StatelessWidget {
  final LastMessageModel lastMessageModel;

  const ConversationScreen({
    required this.lastMessageModel,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
        sl<ConversationCubit>()
          ..getConversation(
              docId: lastMessageModel.docId,
              senderId: lastMessageModel.userId)
          ..getUserOnlineStatus(lastMessageModel.userId!)
          ..getUserLastSeen(lastMessageModel.userId!)
          ..getUserTypingStatus(lastMessageModel.userId!)
          ..updateUnreadMessages(lastMessageModel.docId),
        child: BlocBuilder<ConversationCubit, ConversationState>(
            builder: (context, state) {
              final cubit = ConversationCubit.get(context);
              return state.when(
                onInitial: () => const SizedBox(),
                onLoading: () => const LoadingStateWidget(),
                onLoaded: (data) {
                  return ConversationLayout(
                    userStatus: data.firstModel,
                    dataModel: data.secondModel,
                    messageResult: data.thirdModel,
                    lastMessageModel: lastMessageModel,
                    onlineStatusService: sl<OnlineStatusService>(),
                    cacheHelper: sl<CacheHelper>(),
                    sendMessage: ({
                      required String docId,
                      required String userId,
                      required ConversationModel conversation
                    }) =>
                        cubit.sendMessage(
                            docId: docId,
                            userId: userId,
                            conversation: conversation
                        ),
                    updateTyping: (isTyping) => cubit.updateTyping(isTyping),
                    getOldMessages: cubit.getOldMessages(
                        docId: lastMessageModel.docId),
                    deleteMessages: (messagesIds) =>
                        cubit.deleteMessages(messagesIds: messagesIds,
                            docId: lastMessageModel.docId),
                    clearConversationsList: () =>
                        cubit.clearConversationsList(
                            docId: lastMessageModel.docId),

                  );
                },
                onError: (error) =>
                    error.buildErrorWidget(
                        onRetry: () =>
                        cubit
                          ..getConversation(
                              docId: lastMessageModel.docId,
                              senderId: lastMessageModel.userId)
                          ..getUserOnlineStatus(lastMessageModel.userId!)
                          ..getUserLastSeen(lastMessageModel.userId!)
                          ..getUserTypingStatus(lastMessageModel.userId!)
                          ..updateUnreadMessages(lastMessageModel.docId)
                    ),
              );
            }
        )
    );
  }
}
