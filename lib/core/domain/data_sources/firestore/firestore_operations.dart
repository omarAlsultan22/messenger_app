import 'package:cloud_firestore/cloud_firestore.dart';


abstract class FirestoreOperations{
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String? docId,
  });
}