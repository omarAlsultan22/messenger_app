import 'dart:async';


abstract class IOnlineStatusService {
  Future<void> initialize();

  Future<void> setOnline();

  Future<void> setOffline();

  Stream<bool> getUserTypingStatus(String userId);

  Stream<bool> getUserOnlineStatus(String userId);

  Stream<DateTime> getUserLastSeen(String userId);

  void dispose();
}