import '../../../features/conversation/data/repositories_impl/remote_conversation_repository_impl.dart';
import '../../../features/conversation/data/repositories_impl/local_conversation_repository_impl.dart';
import '../../../features/conversation/data/data_sources/remote/conversation_data_source_impl.dart';
import '../../../features/conversation/domain/use_cases/update_unread_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/clear_conversations_use_case.dart';
import '../../../features/conversation/domain/use_cases/get_conversations_use_case.dart';
import '../../../features/conversation/domain/use_cases/get_old_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/delete_messages_use_case.dart';
import '../../../features/conversation/domain/use_cases/get_background_use_case.dart';
import '../../../features/conversation/domain/use_cases/update_typing_use_case.dart';
import '../../../features/conversation/presentation/cubits/conversation_cubit.dart';
import '../../../features/conversation/domain/use_cases/send_message_use_case.dart';
import 'package:test_app/core/data/data_sources/local/cache_helper_impl.dart';
import '../../services/data/online_status_service.dart';
import '../service _locator.dart';


class ConversationDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton(() =>
        LocalConversationRepositoryImpl(
            cacheHelper: sl<CacheHelperImpl>()));
    sl.registerLazySingleton(() =>
        RemoteConversationRepositoryImpl(
            dataSource: sl<ConversationDataSourceImpl>()));

    // UseCases
    sl.registerLazySingleton(() =>
        UpdateUnreadMessagesUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        ClearConversationsUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        GetConversationsUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        GetOldMessagesUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        DeleteMessagesUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        GetBackgroundUseCase(
            repository: sl<LocalConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        UpdateTypingUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));
    sl.registerLazySingleton(() =>
        SendMessageUseCase(
            repository: sl<RemoteConversationRepositoryImpl>()));

    // Cubit
    sl.registerFactory(() =>
        ConversationCubit(
          updateUnreadMessagesUseCase: sl<UpdateUnreadMessagesUseCase>(),
          clearConversationsUseCase: sl<ClearConversationsUseCase>(),
          getConversationsUseCase: sl<GetConversationsUseCase>(),
          getOldMessagesUseCase: sl<GetOldMessagesUseCase>(),
          deleteMessagesUseCase: sl<DeleteMessagesUseCase>(),
          getBackgroundUseCase: sl<GetBackgroundUseCase>(),
          onlineStatusService: sl<OnlineStatusService>(),
          updateTypingUseCase: sl<UpdateTypingUseCase>(),
          sendMessageUseCase: sl<SendMessageUseCase>(),

        )
    );
  }
}