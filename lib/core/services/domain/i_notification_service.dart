abstract class INotificationService {
  Future<void> initialize();
  Future<void> sendMessage(Map<String, dynamic> data);
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  void handleNotification(Map<String, dynamic> dataMap);
}