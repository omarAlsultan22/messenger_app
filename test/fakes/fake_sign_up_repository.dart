import 'package:test_app/core/data/models/user_model.dart';
import 'package:test_app/features/auth/domain/repositories/sign_up_repository.dart';


class FakeSignUpRepository implements SignUpRepository {
  int createUserInfoCallCount = 0;
  UserModel? lastUserModel;
  Object? createUserInfoError;

  @override
  Future<void> createUserInfo({
    required UserModel userModel,
  }) async {
    createUserInfoCallCount++;
    lastUserModel = userModel;
    if (createUserInfoError != null) throw createUserInfoError!;
  }
}