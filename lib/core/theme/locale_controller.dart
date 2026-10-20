import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the manually selected language. A null locale follows the device.
class LocaleController extends ChangeNotifier {
  static const _preferenceKey = 'kipmarine_locale';
  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('de'),
  ];

  Locale? _locale;
  Locale? get locale => _locale;

  LocaleController() {
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_preferenceKey);
    final nextLocale = languageCode == null
        ? null
        : supportedLocales.where((locale) => locale.languageCode == languageCode).firstOrNull;
    if (_locale != nextLocale) {
      _locale = nextLocale;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale != null &&
        !supportedLocales.any((item) => item.languageCode == locale.languageCode)) {
      return;
    }
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    if (locale == null) {
      await preferences.remove(_preferenceKey);
    } else {
      await preferences.setString(_preferenceKey, locale.languageCode);
    }
  }
}
