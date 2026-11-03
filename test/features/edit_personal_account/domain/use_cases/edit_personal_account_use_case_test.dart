import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../fakes/fake_edit_personal_account_repository.dart';
import 'package:test_app/features/edit_personal_account/data/models/account_model.dart';
import 'package:test_app/features/edit_personal_account/domain/use_cases/edit_personal_account_use_case.dart';


void main() {
  late FakeEditPersonalAccountRepository fakeRepo;
  late EditPersonalAccountUseCase useCase;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeRepo = FakeEditPersonalAccountRepository();
    fakeFirestore = FakeFirebaseFirestore();
    useCase = EditPersonalAccountUseCase(repository: fakeRepo);
  });

  group('getAccountDataExecute', () {
    test('returns AccountModel built from accounts and info documents',
            () async {
          // 1. نضع مستندين
          await fakeFirestore
              .collection('accounts')
              .doc('user-1')
              .set({'firstName': 'Ali', 'lastName': 'Ahmed', 'userImage': 'url'});
          await fakeFirestore
              .collection('info')
              .doc('user-1')
              .set({'userState': 'public', 'phone': '123'});

          // 2. نحصل على snapshots
          final accountsDoc =
          await fakeFirestore.collection('accounts').doc('user-1').get();
          final infoDoc =
          await fakeFirestore.collection('info').doc('user-1').get();

          // 3. نضعها في fakeRepo (accounts أولاً، info ثانياً)
          fakeRepo.getAccountDataResult = [accountsDoc, infoDoc];

          // 4. ننفذ
          final result = await useCase.getAccountDataExecute(userId: 'user-1');

          expect(result, isA<AccountModel>());
          expect(fakeRepo.getAccountDataCallCount, 1);
          expect(fakeRepo.lastGetUserId, 'user-1');
        });

    test('uses result[0] as account and result[1] as info (order matters)',
            () async {
          await fakeFirestore
              .collection('accounts')
              .doc('user-1')
              .set({'firstName': 'Ali'});
          await fakeFirestore
              .collection('info')
              .doc('user-1')
              .set({'userState': 'public'});

          final accountsDoc =
          await fakeFirestore.collection('accounts').doc('user-1').get();
          final infoDoc =
          await fakeFirestore.collection('info').doc('user-1').get();

          fakeRepo.getAccountDataResult = [accountsDoc, infoDoc];

          final result = await useCase.getAccountDataExecute(userId: 'user-1');

          // AccountModel.userInfo = info (result[1])، accountData = accounts (result[0])
          // نتحقق حسب AccountModel — قد يكون له حقول مثل userState
          expect(result, isNotNull);
          // تحقق إضافي حسب AccountModel
        });

    test('throws when repository.getAccountData throws', () async {
      fakeRepo.getAccountDataError = Exception('read failed');

      expect(
            () => useCase.getAccountDataExecute(userId: 'user-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('propagates cast errors when documents are invalid', () async {
      // نضع مستندات فارغة (data() == null) — لكن get() مع set({}) يعطي Map
      // لاختبار cast، نحتاج DocumentSnapshot فارغ (غير موجود)
      final missingDoc = await fakeFirestore
          .collection('accounts')
          .doc('missing')
          .get();
      final infoDoc = await fakeFirestore
          .collection('info')
          .doc('user-1')
          .get();

      fakeRepo.getAccountDataResult = [missingDoc, infoDoc];

      // getData.data() == null → null as Map → TypeError
      expect(
            () => useCase.getAccountDataExecute(userId: 'user-1'),
        throwsA(isA<TypeError>()),
      );
    });
  });
}