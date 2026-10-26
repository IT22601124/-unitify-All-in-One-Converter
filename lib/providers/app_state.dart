import 'package:flutter/material.dart';

import '../core/constants/conversion_catalog.dart';
import '../models/conversion_history.dart';
import '../models/favorite_conversion.dart';
import '../services/local_storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({LocalStorageService? storage})
    : _storage = storage ?? LocalStorageService();
  final LocalStorageService _storage;
  ThemeMode _themeMode = ThemeMode.system;
  int _precision = 4;
  String _defaultCategoryId = 'length';
  List<FavoriteConversion> _favorites = [];
  List<ConversionHistory> _history = [];
  bool _hasCompletedOnboarding = false;

  ThemeMode get themeMode => _themeMode;
  int get precision => _precision;
  String get defaultCategoryId => _defaultCategoryId;
  List<FavoriteConversion> get favorites => List.unmodifiable(_favorites);
  List<ConversionHistory> get history => List.unmodifiable(_history);
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> initialize() async {
    final values = await Future.wait([
      _storage.theme,
      _storage.precision,
      _storage.defaultCategory,
      _storage.favorites,
      _storage.history,
      _storage.onboardingComplete,
    ]);
    _themeMode = switch (values[0] as String?) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _precision = (values[1] as int?)?.clamp(0, 10) ?? 4;
    final storedCategory = values[2] as String?;
    if (storedCategory != null &&
        conversionCatalog.any((c) => c.id == storedCategory)) {
      _defaultCategoryId = storedCategory;
    }
    try {
      _favorites = (values[3] as List<dynamic>)
          .map(
            (item) => FavoriteConversion.fromJson(item as Map<String, dynamic>),
          )
          .where(_validFavorite)
          .toList();
      _history = (values[4] as List<dynamic>)
          .map(
            (item) => ConversionHistory.fromJson(item as Map<String, dynamic>),
          )
          .where(_validHistory)
          .take(100)
          .toList();
    } on Object {
      _favorites = [];
      _history = [];
    }
    _hasCompletedOnboarding = values[5] as bool? ?? false;
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    notifyListeners();
    await _storage.setOnboardingComplete(true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _storage.setTheme(mode.name);
  }

  Future<void> cycleTheme() => setThemeMode(switch (_themeMode) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });
  Future<void> setPrecision(int value) async {
    _precision = value.clamp(0, 10);
    notifyListeners();
    await _storage.setPrecision(_precision);
  }

  Future<void> setDefaultCategory(String categoryId) async {
    _defaultCategoryId = categoryId;
    notifyListeners();
    await _storage.setDefaultCategory(categoryId);
  }

  bool isFavorite(String categoryId, String fromId, String toId) =>
      _favorites.any(
        (f) =>
            f.categoryId == categoryId &&
            f.fromUnitId == fromId &&
            f.toUnitId == toId,
      );

  Future<void> toggleFavorite(FavoriteConversion favorite) async {
    final index = _favorites.indexWhere((item) => item.id == favorite.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.insert(0, favorite);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> clearFavorites() async {
    _favorites = [];
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> addHistory(ConversionHistory entry) async {
    if (_history.isNotEmpty) {
      final latest = _history.first;
      if (latest.categoryId == entry.categoryId &&
          latest.fromUnitId == entry.fromUnitId &&
          latest.toUnitId == entry.toUnitId &&
          latest.input == entry.input) {
        return;
      }
    }
    _history = [entry, ..._history].take(100).toList();
    notifyListeners();
    await _saveHistory();
  }

  Future<void> deleteHistory(String id) async {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _saveHistory();
  }

  Future<void> _saveFavorites() =>
      _storage.setFavorites(_favorites.map((item) => item.toJson()).toList());
  Future<void> _saveHistory() =>
      _storage.setHistory(_history.map((item) => item.toJson()).toList());

  bool _validFavorite(FavoriteConversion favorite) {
    try {
      final category = categoryById(favorite.categoryId);
      category.unit(favorite.fromUnitId);
      category.unit(favorite.toUnitId);
      return true;
    } on Object {
      return false;
    }
  }

  bool _validHistory(ConversionHistory item) {
    try {
      final category = categoryById(item.categoryId);
      category.unit(item.fromUnitId);
      category.unit(item.toUnitId);
      return item.input.isFinite && item.result.isFinite;
    } on Object {
      return false;
    }
  }
}
