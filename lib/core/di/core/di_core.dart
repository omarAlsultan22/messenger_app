import '../../../features/conversation/data/data_sources/remote/firestore_conversation.dart';
import '../../../features/home/data/data_source/firestore_home_service.dart';
import '../../data/data_sources/remote/firestore/firestore_service.dart';
import '../../data/data_sources/remote/firebase_auth_service.dart';
import '../../data/data_sources/local/shared_preferences.dart';
import '../../data/network/connectivity_service.dart';
import '../../services/online_status_service.dart';
import '../../services/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton(() => CacheHelper());
    sl.registerLazySingleton(() => SessionService());
    sl.registerLazySingleton(() => FirestoreService());
    sl.registerLazySingleton(() => OnlineStatusService());
    sl.registerLazySingleton(() => FirebaseAuthService());
    sl.registerLazySingleton(() => ConnectivityService());
    sl.registerLazySingleton(() => FirestoreHomeService());
    sl.registerLazySingleton(() => FirestoreConversationService());
  }
}