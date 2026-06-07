import 'package:test_app/features/conversation/data/repositories_impl/shared_pref_conversation_repository.dart';
import 'package:test_app/features/conversation/data/repositories_impl/firestore_conversation_repository.dart';
import 'package:test_app/features/conversation/data/data_sources/remote/firestore_conversation.dart';
import 'package:test_app/features/conversation/domain/useCases/update_unread_messages_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/clear_conversations_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/get_conversations_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/get_old_messages_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/delete_messages_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/get_background_use_case.dart';
import 'package:test_app/features/conversation/domain/useCases/update_typing_use_case.dart';
import 'package:test_app/features/conversation/presentation/states/conversation_state.dart';
import 'package:test_app/features/conversation/domain/useCases/send_message_use_case.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../../../core/presentation/widgets/states/loading_state.dart';
import 'package:test_app/core/presentation/states/loaded_states.dart';
import '../../../../core/services/online_status_service.dart';
import '../../../../core/data/models/last_message_model.dart';
import '../widgets/layouts/conversation_layout.dart';
import '../../data/models/conversation_model.dart';
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
    final cacheHelper = CacheHelper();
    final firestoreConversationService = FirestoreConversationService();
    final sharedPrefConversationRepository = SharedPrefConversationRepository(
        cacheHelper: cacheHelper);
    final firestoreConversationRepository = FirestoreConversationRepository(
        service: firestoreConversationService);

    final updateUnreadMessagesUseCase = UpdateUnreadMessagesUseCase(
        repository: firestoreConversationRepository);
    final clearConversationsUseCase = ClearConversationsUseCase(
        repository: firestoreConversationRepository);
    final getConversationsUseCase = GetConversationsUseCase(
        repository: firestoreConversationRepository);
    final getOldMessagesUseCase = GetOldMessagesUseCase(
        repository: firestoreConversationRepository);
    final deleteMessagesUseCase = DeleteMessagesUseCase(
        repository: firestoreConversationRepository);
    final getBackgroundUseCase = GetBackgroundUseCase(
        repository: sharedPrefConversationRepository);
    final updateTypingUseCase = UpdateTypingUseCase(
        repository: firestoreConversationRepository);
    final sendMessageUseCase = SendMessageUseCase(
        repository: firestoreConversationRepository);
    final onlineStatusService = OnlineStatusService();

    return BlocProvider(
        create: (context) =>
        ConversationCubit(
            getBackgroundUseCase: getBackgroundUseCase,
            updateUnreadMessagesUseCase: updateUnreadMessagesUseCase,
            getConversationsUseCase: getConversationsUseCase,
            getOldMessagesUseCase: getOldMessagesUseCase,
            clearConversationsUseCase: clearConversationsUseCase,
            deleteMessagesUseCase: deleteMessagesUseCase,
            sendMessageUseCase: sendMessageUseCase,
            updateTypingUseCase: updateTypingUseCase,
            onlineStatusService: onlineStatusService)
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
                onLoaded: (loadedState) {
                  if (loadedState is DoubleModelSuccessState) {
                    ConversationLayout(
                      userStatus: loadedState.firstModel,
                      dataModel: loadedState.secondModel,
                      lastMessageModel: lastMessageModel,
                      onlineStatusService: onlineStatusService,
                      cacheHelper: cacheHelper,
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
                  }
                  return const SizedBox();
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
