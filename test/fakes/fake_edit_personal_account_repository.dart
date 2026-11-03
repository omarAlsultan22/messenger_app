import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/features/edit_personal_account/domain/repositories/edit_personal_account_repository.dart';


class FakeEditPersonalAccountRepository implements EditPersonalAccountRepository {
  // ===== getAccountData =====
  List<DocumentSnapshot<Map<String, dynamic>>>? getAccountDataResult;
  Object? getAccountDataError;
  int getAccountDataCallCount = 0;
  String? lastGetUserId;

  @override
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getAccountData({
    required String userId,
  }) async {
    getAccountDataCallCount++;
    lastGetUserId = userId;
    if (getAccountDataError != null) throw getAccountDataError!;
    return getAccountDataResult!;
  }

  // ===== updateAccountData =====
  int updateAccountDataCallCount = 0;

  @override
  void updateAccountData({
    required String userId,
    required String userImage,
    required String firstName,
    required String lastName,
    required String userState,
  }) {
    updateAccountDataCallCount++;
  }
}