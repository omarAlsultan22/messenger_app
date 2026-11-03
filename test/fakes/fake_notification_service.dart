import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:test_app/core/services/domain/i_notification_service.dart';


class FakeNotificationService implements INotificationService {
  int sendMessageCallCount = 0;

  @override
  Future<void> sendMessage(Map<String, dynamic> data) async {
    sendMessageCallCount++;
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> handleInitialMessage() async {}
  @override
  Future<void> subscribeToTopic(String topic) async {}
  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
  @override
  void handleNotification(Map<String, dynamic> dataMap) {}
  @override
  Future<void> handleBackgroundNotification(RemoteMessage message) async {}
}