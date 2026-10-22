import 'dart:ui';
import '../../../../core/domain/data_sources/cache_helper.dart';
import '../../domain/repositories/local_conversation_repository.dart';


class LocalConversationRepositoryImpl implements LocalConversationRepository {
  final CacheHelper _cacheHelper;

  LocalConversationRepositoryImpl({
    required CacheHelper cacheHelper
  })
      : _cacheHelper = cacheHelper;

  @override
  Future<Map<String, dynamic>> getSavedBackgroundColorAndImage(
      {required String docId}) async {
    final colorValue = await _cacheHelper.getString(key: 'bg_color_$docId');
    final bgImage = await _cacheHelper.getString(key: 'bg_image_$docId');
    final bgColor = Color(int.parse(colorValue));
    return {
      'bgImage': bgImage,
      'bgColor': bgColor,
    };
  }
}