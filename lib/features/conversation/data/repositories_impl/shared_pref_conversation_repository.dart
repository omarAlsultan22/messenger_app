import 'dart:ui';
import '../../domain/repositories/local_conversations_repository.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';


class SharedPrefConversationRepository implements LocalConversationsRepository {
  final CacheHelper _cacheHelper;

  SharedPrefConversationRepository({
    required CacheHelper cacheHelper
  })
      : _cacheHelper = cacheHelper;

  @override
  Future<Map<String, dynamic>> getSavedBackgroundColorAndImage(
      {required String docId}) async {
    final colorValue = await _cacheHelper.getString(key: 'bg_color_$docId');
    final bgImage = await _cacheHelper.getString(key: 'bg_image_$docId');
    final bgColor = colorValue != null ? Color(int.parse(colorValue)) : null;
    return {
      'bgImage': bgImage,
      'bgColor': bgColor,
    };
  }
}