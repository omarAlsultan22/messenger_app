import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ConversationBackgroundManager {
  Color? bgColor;
  String? bgImage;
  SharedPreferences? _prefs;

  static const _bgColor = 'bg_color_';
  static const _bgImage = 'bg_image_';

  void initialize(String userId, SharedPreferences prefs) {
    _prefs = prefs;
    _loadBackgroundSettings(userId);
  }

  Future<void> _loadBackgroundSettings(String userId) async {
    bgColor = _prefs?.getString('$_bgColor$userId') != null
        ? Color(int.parse(_prefs!.getString('$_bgColor$userId')!))
        : null;
    bgImage = _prefs?.getString('$_bgImage$userId');
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
    await _prefs?.setString('$_bgColor$userId', color.value.toString());
    await _prefs?.remove('$_bgImage$userId');
    bgColor = color;
    bgImage = null;
  }

  Future<void> setBackgroundImage(String userId, String imagePath) async {
    await _prefs?.setString('$_bgImage$userId', imagePath);
    await _prefs?.remove('$_bgColor$userId');
    bgImage = imagePath;
    bgColor = null;
  }
}