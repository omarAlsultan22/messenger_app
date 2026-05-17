import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/user_details.dart';
import '../../../conversation/data/data_sources/remote/firebase_firestore.dart';
import '../../domain/repositories/data_repository.dart';
import '../../../conversation_screen/data/data_sources/remote/firebase_firestore.dart';


class FirebaseDataRepository implements DataRepository {
  final FirestoreService _repository;

  FirebaseDataRepository({required FirestoreService repository})
      : _repository = repository;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> signIn({
    required String phone,
  }) async {
    try {
      return await _repository.getDocument(
          collectionPath: 'accounts', docId: UserDetails.userId);
    }
    catch (e) {
      rethrow;
    }
  }
}