import 'firestore_operations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


abstract class FirestoreService implements FirestoreOperations {
  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath
});

  // إضافة بيانات مع إنشاء معرف تلقائي
  Future<String> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  // إضافة بيانات بمعرف محدد
  Future<void> setData({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  });

  Query<Map<String, dynamic>> getSubCollection({
    required String collectionPath,
    required String docId,
    required String subCollectionPath,
  });

  Future<void> updateDocument({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  });
}