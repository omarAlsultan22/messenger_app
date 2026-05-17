import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/networks/local/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/core/config/firebase_options.dart';
import 'package:conditional_builder_null_safety/example/example.dart';


final navigatorKey = GlobalKey<NavigatorState>();.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheHelper.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService._setupBackgroundIsolate();
  await OnlineStatusService().initialize();
  await NotificationService().initialize();

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    NotificationService()._handleNotification(initialMessage.data);

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM token: $newToken');.
    });

    runApp(const MyApp());
  }
}






