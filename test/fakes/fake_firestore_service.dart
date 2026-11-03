import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/core/domain/data_sources/firestore/firestore_service.dart';


class UpdateDocCall {
  final String? docId;
  final String collectionPath;
  final Map<String, dynamic> data;

  UpdateDocCall({
    this.docId,
    required this.collectionPath,
    required this.data,
  });
}

class FakeFirestoreService implements FirestoreService {

  // ===== getDocument =====
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> docs = {};
  Object? getDocumentError;

  void stubDoc({
    required String docId,
    required String collectionPath,
    required DocumentSnapshot<Map<String, dynamic>> snapshot,
  }) {
    docs['$collectionPath/$docId'] = snapshot;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String? docId,
    required String collectionPath,
  }) async {
    if (getDocumentError != null) throw getDocumentError!;
    final snapshot = docs['$collectionPath/$docId'];
    if (snapshot == null) {
      throw Exception('No stub for $collectionPath/$docId');
    }
    return snapshot;
  }

  // ===== createDoc =====
  DocumentReference<Map<String, dynamic>>? createDocResult;
  int createDocCallCount = 0;
  String? lastCreateDocCollectionPath;

  @override
  DocumentReference<Map<String, dynamic>> createDoc({
    required String collectionPath,
  }) {
    createDocCallCount++;
    lastCreateDocCollectionPath = collectionPath;
    return createDocResult!;
  }

  // ===== addData =====
  String addDataResult = 'generated-id';
  int addDataCallCount = 0;
  String? lastAddCollectionPath;
  Map<String, dynamic>? lastAddData;

  @override
  Future<String> addData({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    addDataCallCount++;
    lastAddCollectionPath = collectionPath;
    lastAddData = data;
    return addDataResult;
  }

// ===== setData =====
  int setDataCallCount = 0;
  String? lastSetDocId;
  String? lastSetCollectionPath;
  Map<String, dynamic>? lastSetData;
  Object? setDataError;

  @override
  Future<void> setData({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    setDataCallCount++;
    lastSetDocId = docId;
    lastSetCollectionPath = collectionPath;
    lastSetData = data;
    if (setDataError != null) throw setDataError!;
  }

  // ===== getSubCollection =====
  @override
  Query<Map<String, dynamic>> getSubCollection({
    required String collectionPath,
    required String docId,
    required String subCollectionPath,
  }) =>
      throw UnimplementedError('getSubCollection not stubbed');

  // ===== updateDoc =====
  int updateDocCallCount = 0;
  final List<UpdateDocCall> updateDocCalls = [];

  @override
  Future<void> updateDoc({
    required String? docId,
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    updateDocCallCount++;
    updateDocCalls.add(UpdateDocCall(
      docId: docId,
      collectionPath: collectionPath,
      data: data,
    ));
  }

  // ===== deleteDocument =====
  int deleteDocumentCallCount = 0;

  @override
  Future<void> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    deleteDocumentCallCount++;
  }
}