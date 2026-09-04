import '../../../../core/data/models/user_model.dart';


abstract class SignUpRepository {
  Future<void> createUserInfo({
    required UserModel userModel
  });
}