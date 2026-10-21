import 'dart:io';
import 'package:path/path.dart' as path;


/// ثوابت ومنطق نقي — static لأنها لا تلمس I/O.
class MediaConstants {
  MediaConstants._();

  static const List<String> imageExtensions = [
    'jpg', 'png', 'jpeg', 'gif', 'webp'
  ];

  static const List<String> videoExtensions = [
    'mp4', 'mov', 'avi', 'mkv', 'flv'
  ];

  static const List<String> audioExtensions = [
    'mp3', 'wav', 'aac', 'ogg', 'm4a', 'flac', 'wma', 'aiff', 'opus', 'amr',
  ];

  /// مطابق للأصل: path.extension(...).replaceFirst('.', '')
  static String getExtension(File file) {
    final filePath = file.path.toLowerCase();
    return path.extension(filePath).replaceFirst('.', '');
  }

  /// يصنّف الملف حسب امتداده.
  static MediaCategory classify(File file) {
    final extension = getExtension(file);
    if (imageExtensions.contains(extension)) return MediaCategory.image;
    if (videoExtensions.contains(extension)) return MediaCategory.video;
    if (audioExtensions.contains(extension)) return MediaCategory.audio;
    return MediaCategory.unknown;
  }
}

enum MediaCategory { image, video, audio, unknown }