import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/lib/models/post_model.dart';
import 'package:test_app/lib/models/user_model.dart';
import 'package:test_app/lib/shared/components/components.dart';
import 'package:test_app/lib/shared/cubit_states/cubit_states.dart';

class GetAccountDataCubit extends Cubit<CubitStates> {
  GetAccountDataCubit() : super(InitialState());
  Map<String, dynamic> accountData = {};

  static GetAccountDataCubit get(context) => BlocProvider.of(context);

  Future<void> getAccountData({
    required String userId
  }) async {
    emit(LoadingState(key: 'getAccountData'));
    try {
      final firestore = FirebaseFirestore.instance;
      final result = await Future.wait([
        firestore.collection('accounts').doc(userId).get(),
        firestore.collection('info').doc(userId).get()
      ]);
      final getData = result[0] as DocumentSnapshot;
      final getInfo = result[1] as DocumentSnapshot;
      accountData = await getUserAccount(
          userAccount: getData.data() as Map<String, dynamic>);
      accountData['userState'] = getInfo['userState'] as String;
      print(accountData);
      emit(SuccessState(key: 'getAccountData'));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), key: 'getAccountData'));
    }
  }

  Future<void> updateAccountData({
    required String userId,
    required String userImage,
    required String userName,
    required String userState,
    required String userPhone,
  }) async {
    emit(LoadingState(key: 'updateAccountData'));
    try {
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore.collection('posts').doc();

      PostModel postModel = PostModel(
        userId: userId,
        docId: docRef.id,
        postType: 'profileImage',
        userText: '',
        userPost: userImage,
        dateTime: DateTime.now(),
        userState: 'public',
      );


      UserModel userModel = UserModel(
        userName: userName,
        userImage: docRef.path,
        userPhone: userPhone,
      );

      await Future.wait([
        firestore.collection('posts').add(postModel.toMap()),
        firestore.collection('accounts').doc(userId).update(userModel.toMap()),
        firestore.collection('Info').doc(userId).update({'userState': userState}),
      ]);

      getAccountData(userId: userId);
      emit(SuccessState(key: 'updateAccountData'));
    }
    catch (error) {
      emit(ErrorState(error: error.toString(), key: 'updateAccountData'));
    }
  }
}