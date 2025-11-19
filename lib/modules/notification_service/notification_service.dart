import 'dart:async';
import 'dart:convert';
import '../../../main.dart';
import 'package:flutter/material.dart';
import '../messenger_screen/cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../conversation_screen/conversation_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../online_status_service/online_status_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  StreamSubscription? _messagesSubscription;

  Future<void> initialize() async {
    await _setupFirebase();
    await _setupLocalNotifications();
    _setupInteractedMessage();
    await _setupBackgroundMessageHandler();
  }


  Future<void> _setupFirebase() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('New FCM Token: $newToken');
    });
  }


  Future<void> _setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'social_app_category',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain(
                'id_1',
                'View',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
          ),
        ],
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          if (details.payload != null) {
            handleNotification(jsonDecode(details.payload!));
          }
        },
      );
    } catch (e) {
      debugPrint('Error setting up local notifications: $e');
      rethrow;
    }
  }


  void handleNotification(Map<String, dynamic> data) {
    try {
      final OnlineStatusService onlineStatusService = OnlineStatusService();
      final docId = data['data']['docId'];

      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
            builder: (context) {
              final friendsList = MainScreenCubit
                  .get(context)
                  .friendsList;
              final matchingItem = friendsList.where((item) =>
              item.docId == docId);
              print('..............${matchingItem.first.lastMessage}');
              return ConversationScreen(
                  lastMessageModel: matchingItem.first,
                  onlineStatusService: onlineStatusService
              );
            }
        ),
      );
    }
    catch (e) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('حدث خطأ في فتح المحادثة')),
          ),
        ),
      );
      debugPrint('Error handling notification payload: $e');
    }
  }


  void _setupInteractedMessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.data}');
      print(message.data['docId']);
      handleNotification(message.data);
    });
  }


  Future<void> _setupBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }


  Future<void> _showNotification(RemoteMessage message) async {
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'social_app_channel',
        'Social App Notifications',
        channelDescription: 'Channel for social app notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? 'You have a new notification',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }


  Future<void> sendMessage(Map<String, dynamic> data) async {
    try {
      final senderName = data['userName'];
      final body = data['text'] ?? 'You have a new message';
      print(data['docId']);

      String title = senderName;

      await _showLocalNotification(
        title: title,
        body: body,
        payload: {
          'data': data
        },

      );
    } catch (e) {
      debugPrint('Error sending interaction notification: $e');
    }
  }


  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }


  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }


  Future<void> dispose() async {
    await _messagesSubscription?.cancel();
  }


  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final processedPayload = _processPayload(payload);

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'social_app_channel',
        'Social App Notifications',
        channelDescription: 'Channel for social app notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(processedPayload),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
      debugPrint('Stack trace: ${e.toString()}');
    }
  }


  Map<String, dynamic> _processPayload(Map<String, dynamic> payload) {
    final processed = <String, dynamic>{};

    payload.forEach((key, value) {
      if (value is DateTime) {
        processed[key] = value.toIso8601String();
      } else if (value is Timestamp) {
        processed[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        processed[key] = _processPayload(value);
      } else if (value is List) {
        processed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _processPayload(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          } else if (item is DateTime) {
            return item.toIso8601String();
          }
          return item;
        }).toList();
      } else {
        processed[key] = value;
      }
    });

    return processed;
  }


  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("Handling a background message: ${message.messageId}");
    await handleBackgroundNotification(message);
  }


  static Future<void> handleBackgroundNotification(RemoteMessage message) async {
    await setupBackgroundIsolate();
    final notificationService = NotificationService();
    await notificationService.initialize();
    notificationService.handleNotification(message.data);
  }


  static Future<void> setupBackgroundIsolate() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
  }
}