import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_home_repository.dart';
import '../../../../fakes/fake_notification_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/home/domain/use_cases/get_friends_use_case.dart';


void main() {
  late GetFriendsUseCase useCase;
  late FakeHomeRepository fakeRepo;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeNotificationService fakeNotification;

  setUp(() {
    fakeRepo = FakeHomeRepository();
    fakeNotification = FakeNotificationService();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = GetFriendsUseCase(
      repository: fakeRepo,
      notificationService: fakeNotification,
    );
  });

  group('execute - empty friends list', () {
    test('emits empty list when friendsSnapshot is empty', () async {
      // ننشئ QuerySnapshot فارغة باستخدام fakeFirestore
      final emptySnapshot = await fakeFirestore
          .collection('users')
          .doc('user-1')
          .collection('friends')
          .get();

      fakeRepo.friendsListStream = Stream.value(emptySnapshot);

      final result = await useCase
          .execute(userId: 'user-1')
          .first;

      expect(result, isEmpty);
      expect(fakeRepo.getFriendsListCallCount, 1);
      expect(fakeRepo.lastFriendsDocId, 'user-1');
    });

    test('does not call getLastMessageStream when friends list is empty',
            () async {
          final emptySnapshot = await fakeFirestore
              .collection('users')
              .doc('user-1')
              .collection('friends')
              .get();

          fakeRepo.friendsListStream = Stream.value(emptySnapshot);

          await useCase
              .execute(userId: 'user-1')
              .first;

          expect(fakeRepo.getLastMessageCallCount, 0);
        });
  });
}