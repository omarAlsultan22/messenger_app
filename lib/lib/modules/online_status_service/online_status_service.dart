import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OnlineStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authSubscription;
  bool _isOnline = false;
  bool _isTyping = false;
  DateTime? _lastSeen;

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

    await _firestore.collection('accounts').doc(_auth.currentUser!.uid).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setOffline() async {
    if (_auth.currentUser == null) return;

    await _firestore.collection('accounts').doc(_auth.currentUser!.uid).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }


  Stream<bool> getUserTypingStatus(String userId) {
    return _firestore.collection('accounts').doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['isTyping'] ?? false);
  }

  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore.collection('accounts').doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['isOnline'] ?? false);
  }

  Stream<DateTime> getUserLastSeen(String userId) {
    return _firestore.collection('accounts').doc(userId)
        .snapshots()
        .map((snapshot) => (snapshot.data()?['lastSeen'] as Timestamp).toDate());
  }

  void dispose() {
    _authSubscription.cancel();
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
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