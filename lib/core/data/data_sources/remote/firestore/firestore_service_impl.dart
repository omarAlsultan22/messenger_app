import 'firestore_operations_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/constants/app_durations.dart';
import '../../../../domain/data_sources/firestore/firestore_service.dart';


class FirestoreServiceImpl extends FirestoreOperationsImpl implements FirestoreService{
  static final _firestore = FirebaseFirestore.instance;
  static const _duration = AppDurations.seconds;

  @override
  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
}) {
    final docRef = _firestore.collection(collectionPath).doc();
    return docRef;
  }

  // إضافة بيانات مع إنشاء معرف تلقائي
  @override
  Future<String> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore.collection(collectionPath).add(data).timeout(_duration);
    return docRef.id;
  }

  // إضافة بيانات بمعرف محدد
  @override
  Future<void> setData({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).set(data).timeout(_duration);
  }

  @override
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

  @override
  Future<void> updateDocument({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).update(data).timeout(_duration);
  }

  @override
  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).delete().timeout(_duration);
  }
}