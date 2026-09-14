import 'package:equatable/equatable.dart';

enum AdhkarTime { morning, evening }

class Dhikr extends Equatable {
  const Dhikr({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translations,
    required this.source,
    required this.repeat,
    required this.times,
  });

  final String id;
  final String arabic;
  final String transliteration;
  final Map<String, String> translations;
  final String source;
  final int repeat;

  /// Which daily blocks this dhikr belongs to.
  final List<AdhkarTime> times;

  String translationFor(String lang) =>
      translations[lang] ?? translations['en'] ?? translations.values.first;

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String? ?? '',
      translations: Map<String, String>.from(json['translations'] as Map),
      source: json['source'] as String,
      repeat: json['repeat'] as int? ?? 1,
      times: (json['times'] as List)
          .map((e) => AdhkarTime.values.firstWhere((t) => t.name == e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id];
}
