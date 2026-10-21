import '../../../features/conversation/data/data_sources/remote/conversation_data_source_impl.dart';
import '../../data/data_sources/remote/firestore/firestore_service_impl.dart';
import '../../../features/home/data/data_source/home_data_source_impl.dart';
import 'package:test_app/core/services/data/media_upload_service.dart';
import 'package:test_app/core/services/data/notification_service.dart';
import '../../data/data_sources/remote/auth_service_impl.dart';
import '../../data/data_sources/local/cache_helper_impl.dart';
import '../../network/data/connectivity_service.dart';
import '../../services/data/online_status_service.dart';
import '../../services/data/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton(() => SessionService());
    sl.registerLazySingleton(() => CacheHelperImpl());
    sl.registerLazySingleton(() => AuthServiceImpl());
    sl.registerLazySingleton(() => MediaUploadService());
    sl.registerLazySingleton(() => HomeDataSourceImpl());
    sl.registerLazySingleton(() => OnlineStatusService());
    sl.registerLazySingleton(() => NotificationService());
    sl.registerLazySingleton(() => ConnectivityService());
    sl.registerLazySingleton(() => FirestoreServiceImpl());
    sl.registerLazySingleton(() => ConversationDataSourceImpl());
  }
}