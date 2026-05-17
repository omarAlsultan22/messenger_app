import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  // إضافة بيانات مع إنشاء معرف تلقائي
  Future<String> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _firestore.collection(collectionPath).add(data);
    return docRef.id;
  }

  // إضافة بيانات بمعرف محدد
  Future<void> setData({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }

  // الحصول على مستند محدد
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String docId,
  }) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }

  Query<Map<String, dynamic>> getCollection({
    required String docId,
    required String subCollectionPath,
    required String superCollectionPath,
  }) {
    return _firestore
        .collection(superCollectionPath)
        .doc(docId)
        .collection(subCollectionPath);
  }

  // تحديث مستند محدد
  Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  // حذف مستند محدد
  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  // الاستماع للتحديثات في الوقت الحقيقي لمستند واحد
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  // الاستماع للتحديثات في الوقت الحقيقي لمجموعة كاملة
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
  }) {
    return _firestore.collection(collectionPath).snapshots();
  }
}