import '../di/service _locator.dart';
import '../domain/data_sources/cache_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/domain/i_notification_service.dart';
import '../services/domain/i_online_status_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/core/config/firebase_options.dart';
import 'package:test_app/core/services/data/session_service.dart';
import 'package:test_app/core/errors/exceptions/components_exception.dart';


class InitializationController {
  static final InitializationController _instance =
  InitializationController._internal();

  factory InitializationController() => _instance;

  InitializationController._internal();

  late final CacheHelper _cacheHelper;
  late final SessionService _sessionService;
  late final INotificationService _notificationService;
  late final IOnlineStatusService _onlineStatusService;

  bool _isInitialized = false;
  RemoteMessage? _initialMessage;

  Future<void> _initializeServices() async {
    // 1. تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. تهيئة Firebase Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3. تهيئة CacheHelper
    _cacheHelper = sl<CacheHelper>();
    await _cacheHelper.init();

    // 4. تهيئة SessionService
    _sessionService = sl<SessionService>();
    await _sessionService.loadFromStorage();

    // 5. تهيئة NotificationService (للأمامية)
    _notificationService = sl<INotificationService>();
    await _notificationService.initialize();

    // 6. تهيئة OnlineStatusService
    _onlineStatusService = sl<IOnlineStatusService>();
    await _onlineStatusService.initialize();

    // 7. إعدادات Firebase Messaging
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _initializeServices();
    }
    catch (e) {
      throw ComponentsException(error: e);
    }
    _isInitialized = true;
  }

  Future<void> retryInit() async {
    await _initializeServices();
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
  }
}