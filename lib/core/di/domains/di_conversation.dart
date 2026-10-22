import '../../../features/conversation/data/repositories_impl/remote_conversation_repository_impl.dart';
import '../../../features/conversation/data/repositories_impl/local_conversation_repository_impl.dart';
import '../../../features/conversation/domain/repositories/remote_conversation_repository.dart';
import '../../../features/conversation/domain/repositories/local_conversation_repository.dart';
import '../../../features/conversation/domain/use_cases/update_unread_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/clear_conversations_use_case.dart';
import '../../../features/conversation/domain/data_sources/conversation_data_source.dart';
import '../../../features/conversation/domain/use_cases/get_conversations_use_case.dart';
import '../../../features/conversation/domain/use_cases/get_old_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/delete_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/get_background_use_case.dart';
import '../../../features/conversation/domain/use_cases/update_typing_use_case.dart';
import '../../../features/conversation/presentation/cubits/conversation_cubit.dart';
import '../../../features/conversation/domain/use_cases/send_message_use_case.dart';
import '../../services/domain/i_online_status_service.dart';
import '../../domain/data_sources/cache_helper.dart';
import '../service _locator.dart';


class ConversationDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton<LocalConversationRepository>(() =>
        LocalConversationRepositoryImpl(
            cacheHelper: sl<CacheHelper>()));
    sl.registerLazySingleton<RemoteConversationRepository>(() =>
        RemoteConversationRepositoryImpl(
            dataSource: sl<ConversationDataSource>()));

    // UseCases
    sl.registerLazySingleton<UpdateUnreadMessagesUseCase>(() =>
        UpdateUnreadMessagesUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<ClearConversationsUseCase>(() =>
        ClearConversationsUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<GetConversationsUseCase>(() =>
        GetConversationsUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<GetOldMessagesUseCase>(() =>
        GetOldMessagesUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<DeleteMessagesUseCase>(() =>
        DeleteMessagesUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<GetBackgroundUseCase>(() =>
        GetBackgroundUseCase(
            repository: sl<LocalConversationRepository>()));
    sl.registerLazySingleton<UpdateTypingUseCase>(() =>
        UpdateTypingUseCase(
            repository: sl<RemoteConversationRepository>()));
    sl.registerLazySingleton<SendMessageUseCase>(() =>
        SendMessageUseCase(
            repository: sl<RemoteConversationRepository>()));

    // Cubit
    sl.registerFactory<ConversationCubit>(() =>
        ConversationCubit(
          updateUnreadMessagesUseCase: sl<UpdateUnreadMessagesUseCase>(),
          clearConversationsUseCase: sl<ClearConversationsUseCase>(),
          getConversationsUseCase: sl<GetConversationsUseCase>(),
          getOldMessagesUseCase: sl<GetOldMessagesUseCase>(),
          deleteMessagesUseCase: sl<DeleteMessagesUseCase>(),
          getBackgroundUseCase: sl<GetBackgroundUseCase>(),
          onlineStatusService: sl<IOnlineStatusService>(),
          updateTypingUseCase: sl<UpdateTypingUseCase>(),
          sendMessageUseCase: sl<SendMessageUseCase>(),

        )
    );
  }
}