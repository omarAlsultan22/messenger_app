import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/core/services/data/media_upload_service.dart';
import 'package:test_app/core/services/domain/i_media_upload_service.dart';


void main() {
  late IMediaUploadService service;

  setUp(() {
    service = MediaUploadService();
  });

  group('checkAndUploadFile - unknown files', () {
    test('returns empty map for unknown extension (.pdf)', () async {
      final result = await service.checkAndUploadFile(File('/tmp/doc.pdf'));
      expect(result, isEmpty);
    });

    test('returns empty map for file without extension', () async {
      final result = await service.checkAndUploadFile(File('/tmp/README'));
      expect(result, isEmpty);
    });

    test('returns empty map for unknown extension (.xyz)', () async {
      final result = await service.checkAndUploadFile(File('/tmp/x.xyz'));
      expect(result, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // ملاحظة على ما لم يُختبر هنا (بوعي، وليس إهمالاً):
  //
  // مسارات image / video / audio تستدعي _uploadFile → putFile(File)،
  // وهو يتطلب:
  //   1. ملفاً حقيقياً على القرص (putFile يقرأ bytes من File).
  //   2. FirebaseStorage حقيقياً أو mock متوافقاً.
  //
  // حزمة firebase_storage_mocks غير متوافقة مع إصدار firebase_storage
  // في هذا المشروع (تم التحقق من كل الإصدارات المتاحة).
  //
  // الحل المعتمد رسمياً من Firebase لهذا النوع من التكامل هو
  // Firebase Storage Emulator (Integration Test)، وليس Unit Test.
  //
  // التصنيف (classify) — وهو المنطق الحقيقي — مغطى بالكامل في:
  //   test/core/services/domain/media_constants_test.dart (11 اختباراً)
  // ═══════════════════════════════════════════════════════════════════
}