import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/utils/mappers/user_account_mapper.dart';
import 'package:test_app/features/edit_personal_account/data/models/account_model.dart';
import 'package:test_app/features/edit_personal_account/data/repositories_impl/firestore_edit_personal_account_repository.dart';


class EditPersonalAccountUseCase {
  final FirestoreEditPersonalAccountRepository _repository;

  EditPersonalAccountUseCase(
      {required FirestoreEditPersonalAccountRepository repository})
      : _repository = repository;

  Future<AccountModel?> getAccountDataExecute({
    required String userId
  }) async {
    try {
      final result = await _repository.getAccountData(userId: userId);
      final getData = result[0] as DocumentSnapshot;
      final getInfo = result[1] as DocumentSnapshot;
      final accountData = await UserAccountMapper.enrichUserAccount(
          userAccount: getData.data() as Map<String, dynamic>
      );
      final userInfo = getInfo.data() as Map<String, dynamic>;
      return AccountModel.fromJson(
          userInfo: userInfo,
          accountData: accountData
      );
    }
    catch (e) {
      rethrow;
    }
  }
}