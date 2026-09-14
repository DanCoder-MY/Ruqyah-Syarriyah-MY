import 'package:equatable/equatable.dart';

class Reciter extends Equatable {
  const Reciter({
    required this.id,
    required this.name,
    required this.style,
    required this.isPremium,
    this.avatarAsset,
  });

  final String id;
  final String name;
  final String style;
  final bool isPremium;
  final String? avatarAsset;

  factory Reciter.fromJson(Map<String, dynamic> json) => Reciter(
        id: json['id'] as String,
        name: json['name'] as String,
        style: json['style'] as String? ?? '',
        isPremium: json['isPremium'] as bool? ?? false,
        avatarAsset: json['avatarAsset'] as String?,
      );

  @override
  List<Object?> get props => [id];
}
