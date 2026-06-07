import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/constants/app_durations.dart';
import 'package:test_app/core/data/data_sources/remote/firestore/firestore_base_operations.dart';


class FirestoreBaseService extends FirestoreBaseOperations{
  static final _firestore = FirebaseFirestore.instance;
  static const _duration = AppDurations.seconds;

  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
}) {
    final docRef = _firestore.collection(collectionPath).doc();
    return docRef;
  }

  // إضافة بيانات مع إنشاء معرف تلقائي
  Future<String> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore.collection(collectionPath).add(data).timeout(_duration);
    return docRef.id;
  }

  // إضافة بيانات بمعرف محدد
  Future<void> setData({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).set(data).timeout(_duration);
  }

  Query<Map<String, dynamic>> getSubCollection({
    required String collectionPath,
    required String docId,
    required String subCollectionPath,
  }) {
    return _firestore
        .collection(collectionPath)
        .doc(docId)
        .collection(subCollectionPath);
  }

  Future<void> updateDocument({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).update(data).timeout(_duration);
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).delete().timeout(_duration);
  }
}