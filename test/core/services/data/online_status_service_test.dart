import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/core/services/data/online_status_service.dart';
import 'package:test_app/core/services/domain/i_online_status_service.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late IOnlineStatusService service;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    // 1. مستخدم وهمي
    final mockUser = MockUser(uid: 'user-1', email: 'a@b.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // 2. المستند موجود مسبقاً (لأن setOnline يستخدم update وليس set)
    await fakeFirestore.collection('accounts').doc('user-1').set({
      'isOnline': false,
      'lastSeen': Timestamp.fromDate(DateTime(2024)),
    });

    service = OnlineStatusService(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  group('setOnline', () {
    test('updates isOnline=true and sets lastSeen', () async {
      await service.setOnline();

      final doc = await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .get();
      expect(doc.data()?['isOnline'], true);
      expect(doc.data()?['lastSeen'], isA<Timestamp>());
    });

    test('does nothing when no user is signed in', () async {
      final signedOutAuth = MockFirebaseAuth(signedIn: false);
      final signedOutService = OnlineStatusService(
        firestore: fakeFirestore,
        auth: signedOutAuth,
      );

      await signedOutService.setOnline();

      final doc = await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .get();
      // ما زال false (لم يتغير)
      expect(doc.data()?['isOnline'], false);
    });
  });

  group('setOffline', () {
    test('updates isOnline=false and sets lastSeen', () async {
      await service.setOffline();

      final doc = await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .get();
      expect(doc.data()?['isOnline'], false);
      expect(doc.data()?['lastSeen'], isA<Timestamp>());
    });

    test('does nothing when no user is signed in', () async {
      final signedOutAuth = MockFirebaseAuth(signedIn: false);
      final signedOutService = OnlineStatusService(
        firestore: fakeFirestore,
        auth: signedOutAuth,
      );

      await signedOutService.setOffline();

      final doc = await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .get();
      expect(doc.data()?['isOnline'], false);
    });
  });

  group('getUserOnlineStatus', () {
    test('emits true when isOnline is true', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-2')
          .set({'isOnline': true});

      final stream = service.getUserOnlineStatus('user-2');
      expect(await stream.first, true);
    });

    test('emits false when isOnline is false', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-2')
          .set({'isOnline': false});

      final stream = service.getUserOnlineStatus('user-2');
      expect(await stream.first, false);
    });

    test('emits false when document does not exist', () async {
      final stream = service.getUserOnlineStatus('missing');
      expect(await stream.first, false);
    });
  });

  group('getUserTypingStatus', () {
    test('emits isTyping value', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-2')
          .set({'isTyping': true});

      final stream = service.getUserTypingStatus('user-2');
      expect(await stream.first, true);
    });

    test('emits false when isTyping is missing', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-2')
          .set({'isOnline': true});

      final stream = service.getUserTypingStatus('user-2');
      expect(await stream.first, false);
    });
  });

  group('getUserLastSeen', () {
    test('emits DateTime converted from Timestamp', () async {
      final lastSeen = DateTime(2024, 5, 1, 12, 0);
      await fakeFirestore
          .collection('accounts')
          .doc('user-2')
          .set({'lastSeen': Timestamp.fromDate(lastSeen)});

      final stream = service.getUserLastSeen('user-2');
      final result = await stream.first;
      expect(result, lastSeen);
    });
  });
}