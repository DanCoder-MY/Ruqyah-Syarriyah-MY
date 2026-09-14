import 'package:equatable/equatable.dart';

/// A guided routine composed of ordered du'a references with repeat counts.
class RuqyahSession extends Equatable {
  const RuqyahSession({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    this.isPremium = false,
    this.icon = 'shield',
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<SessionStep> steps;
  final bool isPremium;
  final String icon;

  String titleFor(String lang) => title[lang] ?? title['en'] ?? title.values.first;
  String descriptionFor(String lang) =>
      description[lang] ?? description['en'] ?? description.values.first;

  factory RuqyahSession.fromJson(Map<String, dynamic> json) {
    return RuqyahSession(
      id: json['id'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      steps: (json['steps'] as List)
          .map((e) => SessionStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPremium: json['isPremium'] as bool? ?? false,
      icon: json['icon'] as String? ?? 'shield',
    );
  }

  @override
  List<Object?> get props => [id];
}

class SessionStep extends Equatable {
  const SessionStep({required this.duaId, required this.repeat});

  final String duaId;
  final int repeat;

  factory SessionStep.fromJson(Map<String, dynamic> json) => SessionStep(
        duaId: json['duaId'] as String,
        repeat: json['repeat'] as int? ?? 1,
      );

  @override
  List<Object?> get props => [duaId, repeat];
}
