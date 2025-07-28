import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../layouts/conversation_layout.dart';
import '../../main.dart';
import '../main_screen/cubit.dart';
import '../online_status_service/online_status_service.dart';

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
    //_setupInteractionsListener();
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
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        if (details.payload != null) {
          handleMessage(jsonDecode(details.payload!));
        }
      },
    );
  }

  void handleMessage(Map<String, dynamic> data) {
    try{
          final chatId = data['data']['docId'];
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) {
                final friendsList = MainScreenCubit.get(context).friendsList;
                final lastMessageModel = friendsList.firstWhere((item) => item.docId == chatId);
                return ConversationLayout(
                  lastMessageModel: lastMessageModel,
                  onlineStatusService: OnlineStatusService(),
                );
              }
            ),
          );
      } catch (e) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('لم يتم العثور على المحادثة')),
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
      handleMessage(message.data);
    });
  }

  Future<void> _setupBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }


  /*
  // المرحلة 6: متابعة تفاعلات المستخدم من Firestore
  Future<void> _setupInteractionsListener() async {
    _messagesSubscription?.cancel();
    _messagesSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: UserDetails.userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          _sendInteractionNotification(data);
        }
      }
    });
  }

   */

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
      bool isUrl = data['text']!.isNotEmpty;

      String title = senderName;
      String body = isUrl? data['text'] : 'You have a new message';

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
    notificationService.handleMessage(message.data);
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