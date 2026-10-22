import '../../../features/conversation/data/data_sources/remote/conversation_data_source_impl.dart';
import '../../../features/conversation/domain/data_sources/conversation_data_source.dart';
import '../../data/data_sources/remote/firestore/firestore_service_impl.dart';
import '../../../features/home/data/data_source/home_data_source_impl.dart';
import '../../../features/home/domain/data_source/home_data_source.dart';
import 'package:test_app/core/services/data/media_upload_service.dart';
import 'package:test_app/core/services/data/notification_service.dart';
import '../../domain/data_sources/firestore/firestore_service.dart';
import '../../data/data_sources/remote/auth_service_impl.dart';
import '../../data/data_sources/local/cache_helper_impl.dart';
import '../../services/domain/i_online_status_service.dart';
import '../../services/domain/i_media_upload_service.dart';
import '../../services/domain/i_notification_service.dart';
import '../../network/domain/i_connectivity_service.dart';
import '../../services/data/online_status_service.dart';
import '../../network/data/connectivity_service.dart';
import '../../domain/data_sources/auth_service.dart';
import '../../domain/data_sources/cache_helper.dart';
import '../../services/data/session_service.dart';
import '../service _locator.dart';


class CoreDependencies {
  static void register() {
    sl.registerLazySingleton<CacheHelper>(() => CacheHelperImpl());
    sl.registerLazySingleton<AuthService>(() => AuthServiceImpl());
    sl.registerLazySingleton<SessionService>(() => SessionService());
    sl.registerLazySingleton<HomeDataSource>(() => HomeDataSourceImpl());
    sl.registerLazySingleton<FirestoreService>(() => FirestoreServiceImpl());
    sl.registerLazySingleton<IMediaUploadService>(() => MediaUploadService());
    sl.registerLazySingleton<IOnlineStatusService>(() => OnlineStatusService());
    sl.registerLazySingleton<INotificationService>(() => NotificationService());
    sl.registerLazySingleton<IConnectivityService>(() => ConnectivityService());
    sl.registerLazySingleton<ConversationDataSource>(() => ConversationDataSourceImpl());
  }
}