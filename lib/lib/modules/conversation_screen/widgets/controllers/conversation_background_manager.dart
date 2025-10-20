import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ConversationBackgroundManager {
  Color? bgColor;
  String? bgImage;
  SharedPreferences? _prefs;

  void initialize(String userId, SharedPreferences prefs) {
    _prefs = prefs;
    _loadBackgroundSettings(userId);
  }

  Future<void> _loadBackgroundSettings(String userId) async {
    bgColor = _prefs?.getString('bg_color_$userId') != null
        ? Color(int.parse(_prefs!.getString('bg_color_$userId')!))
        : null;
    bgImage = _prefs?.getString('bg_image_$userId');
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
    await _prefs?.setString('bg_color_$userId', color.value.toString());
    await _prefs?.remove('bg_image_$userId');
    bgColor = color;
    bgImage = null;
  }

  Future<void> setBackgroundImage(String userId, String imagePath) async {
    await _prefs?.setString('bg_image_$userId', imagePath);
    await _prefs?.remove('bg_color_$userId');
    bgImage = imagePath;
    bgColor = null;
  }
}