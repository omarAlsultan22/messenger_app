import 'package:flutter_test/flutter_test.dart';
import '../../../../fakes/fake_firestore_service.dart';
import 'package:test_app/core/data/models/user_model.dart';
import 'package:test_app/features/auth/domain/repositories/sign_up_repository.dart';
import 'package:test_app/features/auth/data/repositories_impl/sign_up_repository_impl.dart';


void main() {
  late FakeFirestoreService fakeDataSource;
  late SignUpRepository repository;

  setUp(() {
    fakeDataSource = FakeFirestoreService();
    repository = SignUpRepositoryImpl(service: fakeDataSource);
  });

  group('createUserInfo', () {
    test('calls setData with "accounts" collection and userModel data',
            () async {
          final userModel = UserModel(
            userId: 'user-1',
            firstName: 'Ali',
            lastName: 'Ahmed',
          );

          await repository.createUserInfo(userModel: userModel);

          expect(fakeDataSource.setDataCallCount, 1);
          expect(fakeDataSource.lastSetCollectionPath, 'accounts');
          expect(fakeDataSource.lastSetDocId, 'user-1');
          expect(fakeDataSource.lastSetData, userModel.toJson());
        });

    test('uses empty string docId when userId is null', () async {
      final userModel = UserModel(
        userId: null, // ← null
        firstName: 'Ali',
      );

      await repository.createUserInfo(userModel: userModel);

      expect(fakeDataSource.lastSetDocId, '');
    });

    test('propagates errors from setData', () async {
      fakeDataSource.setDataError = Exception('write failed');
      final userModel = UserModel(userId: 'user-1');

      expect(
            () => repository.createUserInfo(userModel: userModel),
        throwsA(isA<Exception>()),
      );
    });
  });
}