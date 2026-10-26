import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _themeKey = 'theme_mode';
  static const _precisionKey = 'decimal_precision';
  static const _defaultCategoryKey = 'default_category';
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _onboardingCompleteKey = 'onboarding_complete';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();
  Future<String?> get theme async => (await _preferences).getString(_themeKey);
  Future<int?> get precision async =>
      (await _preferences).getInt(_precisionKey);
  Future<String?> get defaultCategory async =>
      (await _preferences).getString(_defaultCategoryKey);
  Future<List<dynamic>> get favorites async => _readList(_favoritesKey);
  Future<List<dynamic>> get history async => _readList(_historyKey);
  Future<bool?> get onboardingComplete async =>
      (await _preferences).getBool(_onboardingCompleteKey);
  Future<void> setTheme(String value) async =>
      (await _preferences).setString(_themeKey, value);
  Future<void> setPrecision(int value) async =>
      (await _preferences).setInt(_precisionKey, value);
  Future<void> setDefaultCategory(String value) async =>
      (await _preferences).setString(_defaultCategoryKey, value);
  Future<void> setFavorites(List<Map<String, dynamic>> value) async =>
      _writeList(_favoritesKey, value);
  Future<void> setHistory(List<Map<String, dynamic>> value) async =>
      _writeList(_historyKey, value);
  Future<void> setOnboardingComplete(bool value) async =>
      (await _preferences).setBool(_onboardingCompleteKey, value);

  Future<List<dynamic>> _readList(String key) async {
    try {
      final raw = (await _preferences).getString(key);
      return raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    } on Object {
      return <dynamic>[];
    }
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> value) async {
    try {
      await (await _preferences).setString(key, jsonEncode(value));
    } on Object {
      // Persistence failure should not make the converter unusable.
    }
  }
}
