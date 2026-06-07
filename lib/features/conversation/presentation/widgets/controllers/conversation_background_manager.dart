import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_app/core/data/data_sources/local/shared_preferences.dart';


class ConversationBackgroundManager {
  Color? bgColor;
  String? bgImage;
  CacheHelper? _cacheHelper;

  static const _bgColor = 'bg_color_';
  static const _bgImage = 'bg_image_';

  void initialize(String userId, CacheHelper cacheHelper) {
    _cacheHelper = cacheHelper;
    _loadBackgroundSettings(userId);
  }

  Future<void> _loadBackgroundSettings(String userId) async {
    bgColor = _cacheHelper?.getString(key: '$_bgColor$userId') != null
        ? Color(
        int.parse(await _cacheHelper!.getString(key: '$_bgColor$userId')))
        : null;
    bgImage = await _cacheHelper?.getString(key: '$_bgImage$userId');
  }

  BoxDecoration? buildBackgroundDecoration() {
    if (bgImage != null && File(bgImage!).existsSync()) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(bgImage!)),
          fit: BoxFit.cover,
        ),
      );
    } else if (bgColor != null) {
      return BoxDecoration(color: bgColor);
    }
    return null;
  }

  Future<void> setBackgroundColor(String userId, Color color) async {
    await _cacheHelper?.setString(
        key: '$_bgColor$userId', value: color.value.toString());
    await _cacheHelper?.removeValue(key: '$_bgImage$userId');
    bgColor = color;
    bgImage = null;
  }

  Future<void> setBackgroundImage(String userId, String imagePath) async {
    await _cacheHelper?.setString(key: '$_bgImage$userId', value: imagePath);
    await _cacheHelper?.removeValue(key: '$_bgColor$userId');
    bgImage = imagePath;
    bgColor = null;
  }
}