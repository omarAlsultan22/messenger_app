import '../di/service _locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/core/config/firebase_options.dart';
import 'package:test_app/core/services/session_service.dart';
import 'package:test_app/core/services/notification_service.dart';
import 'package:test_app/core/services/online_status_service.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';


class InitializationController {
  static final InitializationController _instance =
  InitializationController._internal();

  factory InitializationController() => _instance;

  InitializationController._internal();

  late final CacheHelper _cacheHelper;
  late final SessionService _sessionService;
  late final NotificationService _notificationService;
  late final OnlineStatusService _onlineStatusService;

  bool _isInitialized = false;
  RemoteMessage? _initialMessage;

  // Getters للوصول للخدمات إذا لزم الأمر
  CacheHelper get cacheHelper => _cacheHelper;
  SessionService get sessionService => _sessionService;
  NotificationService get notificationService => _notificationService;
  OnlineStatusService get onlineStatusService => _onlineStatusService;
  RemoteMessage? get initialMessage => _initialMessage;

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

    // 5. تهيئة NotificationService (للخلفية)
    await NotificationService.setupBackgroundIsolate();

    // 6. تهيئة OnlineStatusService
    _onlineStatusService = OnlineStatusService();
    await _onlineStatusService.initialize();

    // 7. تهيئة NotificationService (للأمامية)
    _notificationService = NotificationService();
    await _notificationService.initialize();

    // 8. الحصول على الرسالة الأولية
    _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // 9. التعامل مع الرسالة الأولية إذا وجدت
    if (_initialMessage != null) {
      _notificationService.handleNotification(_initialMessage!.data);
    }

    // 10. إعدادات Firebase Messaging
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 11. الاستماع لتحديث التوكن
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });
  }

  Future<void> init() async {
    if (_isInitialized) return;

    await _initializeServices();
    _isInitialized = true;
  }

  Future<void> retryInit() async {
    // إعادة محاولة التهيئة في حالة الفشل
    await _initializeServices();
    _isInitialized = true;
  }

  // التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  // إعادة تعيين الحالة (إذا لزم الأمر)
  void reset() {
    _isInitialized = false;
  }
}