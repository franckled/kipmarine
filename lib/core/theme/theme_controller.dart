import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste le choix du thème KipMarine : système, clair ou sombre.
class ThemeController extends ChangeNotifier {
  static const _preferenceKey = 'kipmarine_theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_preferenceKey);
    final mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, value);
  }
}
