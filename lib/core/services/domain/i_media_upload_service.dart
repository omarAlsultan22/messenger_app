import 'dart:io';


abstract class IMediaUploadService {
  Future<File?> pickImage();
  Future<File?> pickVideo();
  Future<String?> checkAndUploadFile(File file);
}