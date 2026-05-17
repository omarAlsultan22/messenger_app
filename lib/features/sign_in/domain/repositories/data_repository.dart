import 'package:cloud_firestore/cloud_firestore.dart';


abstract class DataRepository {
  Future<DocumentSnapshot<Map<String, dynamic>>> signIn({
    required String phone,
  });
}