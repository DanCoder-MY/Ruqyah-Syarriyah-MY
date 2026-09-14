import 'package:equatable/equatable.dart';

/// Content categories for Ruqyah entries.
enum RuqyahCategory {
  protection,
  healing,
  evilEye,
  sihr,
  anxiety,
  sleep,
  waking;

  static RuqyahCategory fromKey(String key) => RuqyahCategory.values.firstWhere(
        (c) => c.name == key,
        orElse: () => RuqyahCategory.protection,
      );
}

/// A single Ruqyah entry: Qur'anic verse(s) or an authentic Sunnah supplication.
/// Every entry MUST carry a verifiable [source] citation.
class Dua extends Equatable {
  const Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translations,
    required this.source,
    required this.category,
    this.repeat = 1,
    this.audioAsset,
    this.audioUrl,
    this.reference,
  });

  final String id;

  /// Localized titles keyed by language code (en, ar, ms).
  final Map<String, String> title;

  /// Uthmani Arabic text.
  final String arabic;

  final String transliteration;

  /// Translations keyed by language code.
  final Map<String, String> translations;

  /// Human-readable source, e.g. "Qur'an 2:255" or "Sahih al-Bukhari 5017".
  final String source;

  final RuqyahCategory category;

  /// Recommended repetition count (e.g. 3x for the last two surahs).
  final int repeat;

  /// Bundled audio asset path (offline day one).
  final String? audioAsset;

  /// Remote audio URL for downloadable packs.
  final String? audioUrl;

  /// Optional short reference note (grading, context).
  final String? reference;

  String titleFor(String lang) => title[lang] ?? title['en'] ?? title.values.first;

  String translationFor(String lang) =>
      translations[lang] ?? translations['en'] ?? translations.values.first;

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String? ?? '',
      translations: Map<String, String>.from(json['translations'] as Map),
      source: json['source'] as String,
      category: RuqyahCategory.fromKey(json['category'] as String),
      repeat: json['repeat'] as int? ?? 1,
      audioAsset: json['audioAsset'] as String?,
      audioUrl: json['audioUrl'] as String?,
      reference: json['reference'] as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}
