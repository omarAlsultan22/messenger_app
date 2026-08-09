import '../../../features/conversation/data/repositories_impl/shared_pref_conversation_repository.dart';
import '../../../features/conversation/data/repositories_impl/firestore_conversation_repository.dart';
import '../../../features/conversation/domain/useCases/update_unread_messages_use_case.dart';
import '../../../features/conversation/data/data_sources/remote/firestore_conversation.dart';
import '../../../features/conversation/domain/useCases/clear_conversations_use_case.dart';
import '../../../features/conversation/domain/useCases/get_conversations_use_case.dart';
import '../../../features/conversation/domain/useCases/get_old_messages_use_case.dart';
import '../../../features/conversation/domain/useCases/delete_messages_use_case.dart';
import '../../../features/conversation/domain/useCases/get_background_use_case.dart';
import '../../../features/conversation/domain/useCases/update_typing_use_case.dart';
import '../../../features/conversation/presentation/cubits/conversation_cubit.dart';
import '../../../features/conversation/domain/useCases/send_message_use_case.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';
import '../../services/online_status_service.dart';
import '../service _locator.dart';


class ConversationDependencies {
  static void register() {
    // Repositories
    sl.registerLazySingleton(() =>
        SharedPrefConversationRepository(
            cacheHelper: sl<CacheHelper>()));
    sl.registerLazySingleton(() =>
        FirestoreConversationRepository(
            service: sl<FirestoreConversationService>()));

    // UseCases
    sl.registerLazySingleton(() =>
        UpdateUnreadMessagesUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        ClearConversationsUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        GetConversationsUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        GetOldMessagesUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        DeleteMessagesUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        GetBackgroundUseCase(
            repository: sl<SharedPrefConversationRepository>()));
    sl.registerLazySingleton(() =>
        UpdateTypingUseCase(
            repository: sl<FirestoreConversationRepository>()));
    sl.registerLazySingleton(() =>
        SendMessageUseCase(
            repository: sl<FirestoreConversationRepository>()));

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