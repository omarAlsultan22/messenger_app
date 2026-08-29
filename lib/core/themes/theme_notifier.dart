import 'package:flutter/material.dart';
import '../data/data_sources/local/cache_helper.dart';


class ThemeNotifier extends ChangeNotifier {
  final CacheHelper _cacheHelper;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier({required CacheHelper cacheHelper}) :
        _cacheHelper = cacheHelper {
    _loadTheme();
  }

  static const _dark = 'dark';
  static const _light = 'light';
  static const _theme = 'theme';
  static const _system = 'system';

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }
    setTheme(_themeMode);
    notifyListeners();
  }

  void _loadTheme() async {
    try {
      String? theme = await _cacheHelper.getString(key: _theme);

      if (theme == _dark) {
        _themeMode = ThemeMode.dark;
      } else if (theme == _light) {
        _themeMode = ThemeMode.light;
      } else if (theme == _system) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.system;
        await _cacheHelper.setString(key: _theme, value: _system);
      }
      notifyListeners();
    } catch (e) {
      print("Error loading theme: $e");
    }
  }

  void setTheme(ThemeMode mode) {
    late String themeValue;
    switch (mode) {
      case ThemeMode.light:
        themeValue = _light;
        break;
      case ThemeMode.dark:
        themeValue = _dark;
        break;
      case ThemeMode.system:
        themeValue = _system;
        break;
    }

    _cacheHelper.setString(key: _theme, value: themeValue);
    notifyListeners();
  }
}