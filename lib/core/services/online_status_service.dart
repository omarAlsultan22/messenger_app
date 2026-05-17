import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class OnlineStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authSubscription;

  static const _isOnline = 'isOnline';
  static const _lastSeen = 'lastSeen';
  static const _accounts = 'accounts';

  Future<void> initialize() async {
    await Firebase.initializeApp();

    // تتبع حالة تسجيل الدخول/الخروج
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _setOnline();
      } else {
        await _setOffline();
      }
    });

    // تحديث الحالة عند فتح/إغلاق التطبيق
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async => await _setOnline(),
        detachCallBack: () async => await _setOffline(),
      ),
    );
  }

  Future<void> _setOnline() async {
    if (_auth.currentUser == null) return;

    await _firestore.collection(_accounts).doc(_auth.currentUser!.uid).update({
      _isOnline: true,
      _lastSeen: FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setOffline() async {
    if (_auth.currentUser == null) return;

    await _firestore.collection(_accounts).doc(_auth.currentUser!.uid).update({
      _isOnline: false,
      _lastSeen: FieldValue.serverTimestamp(),
    });
  }


  Stream<bool> getUserTypingStatus(String userId) {
    const isTyping = 'isTyping';
    return _firestore.collection(_accounts).doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?[isTyping] ?? false);
  }

  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore.collection(_accounts).doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?[_isOnline] ?? false);
  }

  Stream<DateTime> getUserLastSeen(String userId) {
    return _firestore.collection(_accounts).doc(userId)
        .snapshots()
        .map((snapshot) => (snapshot.data()?[_lastSeen] as Timestamp).toDate());
  }

  void dispose() {
    _authSubscription.cancel();
  }
}


class LifecycleEventHandler extends WidgetsBindingObserver {.
  final Function resumeCallBack;
  final Function detachCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.detachCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachCallBack();
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}