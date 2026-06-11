import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';


abstract class MediaUploadService {

  static final ImagePicker _picker = ImagePicker();

  static const List<String> imageExtensions = [
    'jpg',
    'png',
    'jpeg',
    'gif',
    'webp'
  ];
  static const List<String> videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'flv'
  ];
  static const List<String> audioExtensions = [
    'mp3', // الأكثر شيوعاً
    'wav', // صوت غير مضغوط بجودة عالية
    'aac', // Advanced Audio Coding
    'ogg', // مفتوح المصدر
    'm4a', // Apple Audio
    'flac', // Free Lossless Audio Codec
    'wma', // Windows Media Audio
    'aiff', // Audio Interchange File Format
    'opus', // فعال للبث عبر الإنترنت
    'amr', // Adaptive Multi-Rate (شائع في التسجيلات الصوتية)
  ];


  static Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> checkAndUploadFile(File file) async {
    try {
      String filePath = file.path.toLowerCase();
      String extension = path.extension(filePath).replaceFirst('.', '');


      if (imageExtensions.contains(extension)) {
        return await _uploadFile(file, 'images');
      } else if (videoExtensions.contains(extension)) {
        return await _uploadFile(file, 'videos');
      }
      else if (audioExtensions.contains(extension)) {
        return await _uploadFile(file, 'audios');
      }
      else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future <String?> _uploadFile(File file, String folderName) async {
    try {
      String fileName = path.basename(file.path);
      Reference storageReference =
      FirebaseStorage.instance.ref().child('$folderName/$fileName');

      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await storageReference.getDownloadURL();
        print('File uploaded to $folderName/$fileName');
        return downloadUrl;
      } else {
        print('❌ Upload failed');
        return null;
      }
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
}
