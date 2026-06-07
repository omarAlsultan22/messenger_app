import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'core/services/online_status_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/core/config/firebase_options.dart';
import 'core/data/data_sources/local/shared_preferences.dart';
import 'package:conditional_builder_null_safety/example/example.dart';


final navigatorKey = GlobalKey<NavigatorState>();.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cacheHelper = CacheHelper();
  await cacheHelper.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
  );

  await NotificationService.setupBackgroundIsolate();
  await OnlineStatusService().initialize();
  await NotificationService().initialize();

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    NotificationService().handleNotification(initialMessage.data);

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');
    });
    runApp(const MyApp());
  }
}






