abstract final class AppConstants {
  static const String appName = "Ruqyah Syar'iyyah";
  static const String appTagline = 'Pro Edition';

  // Asset content paths (bundled JSON).
  static const String duasAsset = 'assets/content/duas.json';
  static const String sessionsAsset = 'assets/content/sessions.json';
  static const String adhkarAsset = 'assets/content/adhkar.json';
  static const String recitersAsset = 'assets/content/reciters.json';

  // Hive box names.
  static const String settingsBox = 'settings';
  static const String bookmarksBox = 'bookmarks';
  static const String progressBox = 'progress';
  static const String downloadsBox = 'downloads';

  // Settings keys.
  static const String kThemeMode = 'theme_mode';
  static const String kLocale = 'locale';
  static const String kArabicScale = 'arabic_scale';
  static const String kShowTransliteration = 'show_transliteration';
  static const String kShowTranslation = 'show_translation';
  static const String kIsPremium = 'is_premium';
  static const String kOnboardingDone = 'onboarding_done';

  // Remote audio CDN base (configure before release).
  static const String audioCdnBase = 'https://cdn.example.com/ruqyah/audio';

  // RevenueCat public API key (inject via --dart-define in CI).
  static const String revenueCatApiKey = String.fromEnvironment('RC_API_KEY');
  static const String premiumEntitlementId = 'pro';
}
