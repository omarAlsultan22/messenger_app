import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_home_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:test_app/features/home/domain/use_cases/get_profile_use_case.dart';


void main() {
  late GetProfileUseCase useCase;
  late FakeHomeRepository fakeRepo;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeRepo = FakeHomeRepository();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = GetProfileUseCase(repository: fakeRepo);
  });

  group('execute', () {
    test('returns userImage string when it is a String', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .set({'userImage': 'https://example.com/avatar.jpg'});
      final doc =
      await fakeFirestore.collection('accounts').doc('user-1').get();
      fakeRepo.accountDataResult = doc;

      final result = await useCase.execute(userId: 'user-1');

      expect(result, 'https://example.com/avatar.jpg');
    });

    test('resolves DocumentReference to its userPost string', () async {
      await fakeFirestore
          .collection('images')
          .doc('img-1')
          .set({'userPost': 'https://cdn.example.com/avatar.png'});

      final imageRef = fakeFirestore.collection('images').doc('img-1');
      await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .set({'userImage': imageRef});

      final doc =
      await fakeFirestore.collection('accounts').doc('user-1').get();
      fakeRepo.accountDataResult = doc;

      final result = await useCase.execute(userId: 'user-1');

      expect(result, 'https://cdn.example.com/avatar.png');
    });

    test('returns empty string when referenced image doc does not exist',
            () async {
          final imageRef = fakeFirestore.collection('images').doc('missing');
          await fakeFirestore
              .collection('accounts')
              .doc('user-1')
              .set({'userImage': imageRef});

          final doc =
          await fakeFirestore.collection('accounts').doc('user-1').get();
          fakeRepo.accountDataResult = doc;

          final result = await useCase.execute(userId: 'user-1');

          expect(result, '');
        });

    test('returns empty string when userImage is missing', () async {
      await fakeFirestore
          .collection('accounts')
          .doc('user-1')
          .set({'name': 'Ali'});
      final doc =
      await fakeFirestore.collection('accounts').doc('user-1').get();
      fakeRepo.accountDataResult = doc;

      final result = await useCase.execute(userId: 'user-1');

      // userImage = null → not DocumentReference → return null as String?
      // لكن return type is String → قد يرمي TypeError
      expect(result, '');
    });

    test('returns empty string when repository.getAccountData throws', () async {
      // نجعل fakeRepo يرمي
      // FakeHomeRepository.getAccountData يعيد accountDataResult!
      // إذا كان null → TypeError (يمسكه catch → '')
      fakeRepo.accountDataResult = null;

      final result = await useCase.execute(userId: 'user-1');

      expect(result, '');
    });
  });
}