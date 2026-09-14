import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.arabicScale = 1.0,
    this.showTransliteration = true,
    this.showTranslation = true,
    this.isPremium = false,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final double arabicScale;
  final bool showTransliteration;
  final bool showTranslation;
  final bool isPremium;

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    double? arabicScale,
    bool? showTransliteration,
    bool? showTranslation,
    bool? isPremium,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
      arabicScale: arabicScale ?? this.arabicScale,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._box) : super(const SettingsState()) {
    _load();
  }

  final Box<dynamic> _box;

  void _load() {
    state = SettingsState(
      themeMode: ThemeMode.values[_box.get(AppConstants.kThemeMode,
          defaultValue: ThemeMode.system.index) as int],
      locale: _box.get(AppConstants.kLocale) != null
          ? Locale(_box.get(AppConstants.kLocale) as String)
          : null,
      arabicScale:
          (_box.get(AppConstants.kArabicScale, defaultValue: 1.0) as num)
              .toDouble(),
      showTransliteration:
          _box.get(AppConstants.kShowTransliteration, defaultValue: true) as bool,
      showTranslation:
          _box.get(AppConstants.kShowTranslation, defaultValue: true) as bool,
      isPremium: _box.get(AppConstants.kIsPremium, defaultValue: false) as bool,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _box.put(AppConstants.kThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale? locale) {
    if (locale == null) {
      _box.delete(AppConstants.kLocale);
      state = state.copyWith(clearLocale: true);
    } else {
      _box.put(AppConstants.kLocale, locale.languageCode);
      state = state.copyWith(locale: locale);
    }
  }

  void setArabicScale(double scale) {
    _box.put(AppConstants.kArabicScale, scale);
    state = state.copyWith(arabicScale: scale);
  }

  void setShowTransliteration(bool value) {
    _box.put(AppConstants.kShowTransliteration, value);
    state = state.copyWith(showTransliteration: value);
  }

  void setShowTranslation(bool value) {
    _box.put(AppConstants.kShowTranslation, value);
    state = state.copyWith(showTranslation: value);
  }

  void setPremium(bool value) {
    _box.put(AppConstants.kIsPremium, value);
    state = state.copyWith(isPremium: value);
  }
}

final settingsBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>(AppConstants.settingsBox);
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref.watch(settingsBoxProvider));
});

/// Convenience provider exposing the active language code for content lookups.
final languageCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(settingsControllerProvider).locale;
  return locale?.languageCode ?? 'en';
});
