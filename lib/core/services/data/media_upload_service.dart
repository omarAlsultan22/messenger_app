import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:test_app/core/services/domain/media_constants.dart';
import 'package:test_app/core/services/domain/i_media_upload_service.dart';


class MediaUploadService implements IMediaUploadService {
  // Singleton — متسق مع NotificationService.
  static final MediaUploadService _instance = MediaUploadService._internal();
  factory MediaUploadService() => _instance;
  MediaUploadService._internal();

  final ImagePicker _picker = ImagePicker();

  // ==================== العقد العام ====================

  @override
  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<File?> pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> checkAndUploadFile(File file) async {
    try {
      final category = MediaConstants.classify(file);

      switch (category) {
        case MediaCategory.image:
          return await _uploadFile(file, 'images');
        case MediaCategory.video:
          return await _uploadFile(file, 'videos');
        case MediaCategory.audio:
          return await _uploadFile(file, 'audios');
        case MediaCategory.unknown:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ==================== تفاصيل التنفيذ (خاصة) ====================

  Future<String?> _uploadFile(File file, String folderName) async {
    try {
      final fileName = path.basename(file.path);
      final storageReference =
      FirebaseStorage.instance.ref().child('$folderName/$fileName');

      final uploadTask = storageReference.putFile(file);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await storageReference.getDownloadURL();
        debugPrint('File uploaded to $folderName/$fileName');
        return downloadUrl;
      } else {
        debugPrint('❌ Upload failed');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }
}