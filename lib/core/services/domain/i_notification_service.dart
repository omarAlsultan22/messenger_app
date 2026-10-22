import 'package:firebase_messaging/firebase_messaging.dart';


abstract class INotificationService {
  Future<void> initialize();

  Future<void> handleInitialMessage();

  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);

  Future<void> sendMessage(Map<String, dynamic> data);

  void handleNotification(Map<String, dynamic> dataMap);

  Future<void> handleBackgroundNotification(RemoteMessage message);
}