import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';
import 'package:test_app/lib/shared/local/shared_preferences.dart';
import '../../shared/components/constants.dart';

class SignInCubit extends Cubit<CubitStates> {
  SignInCubit() : super(InitialState());

  static SignInCubit get(context) => BlocProvider.of(context);

  Future<void> signInWithPhoneNumber({
    required String phone,
  }) async {
    emit(LoadingState());

    try {
      final doc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc( UserDetails.userId)
          .get();

      if (!doc.exists) {
        emit(ErrorState(error: "User not found"));
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      UserDetails.userId = data['userId'] as String;
      final userPhone = data['userPhone'] as String;

      if (phone == userPhone) {
        CacheHelper.serStringValue(key: 'isSigned', value: userPhone);
        emit(SuccessState());
      } else {
        emit(ErrorState(error: "Phone number does not match"));
      }
    } catch (error) {
      emit(ErrorState(error: error.toString()));
    }
  }
}