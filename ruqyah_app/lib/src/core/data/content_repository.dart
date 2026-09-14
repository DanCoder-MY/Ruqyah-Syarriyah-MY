import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/adhkar/domain/dhikr.dart';
import '../../features/library/domain/dua.dart';
import '../../features/player/domain/reciter.dart';
import '../../features/sessions/domain/session.dart';
import '../constants/app_constants.dart';

/// Loads bundled JSON content from assets. Content ships in-app so the
/// experience works fully offline on first launch.
class ContentRepository {
  ContentRepository();

  List<Dua>? _duasCache;
  List<RuqyahSession>? _sessionsCache;
  List<Dhikr>? _adhkarCache;
  List<Reciter>? _recitersCache;

  Future<List<Dua>> loadDuas() async {
    if (_duasCache != null) return _duasCache!;
    final raw = await rootBundle.loadString(AppConstants.duasAsset);
    final list = (jsonDecode(raw) as List)
        .map((e) => Dua.fromJson(e as Map<String, dynamic>))
        .toList();
    return _duasCache = list;
  }

  Future<List<RuqyahSession>> loadSessions() async {
    if (_sessionsCache != null) return _sessionsCache!;
    final raw = await rootBundle.loadString(AppConstants.sessionsAsset);
    final list = (jsonDecode(raw) as List)
        .map((e) => RuqyahSession.fromJson(e as Map<String, dynamic>))
        .toList();
    return _sessionsCache = list;
  }

  Future<List<Dhikr>> loadAdhkar() async {
    if (_adhkarCache != null) return _adhkarCache!;
    final raw = await rootBundle.loadString(AppConstants.adhkarAsset);
    final list = (jsonDecode(raw) as List)
        .map((e) => Dhikr.fromJson(e as Map<String, dynamic>))
        .toList();
    return _adhkarCache = list;
  }

  Future<List<Reciter>> loadReciters() async {
    if (_recitersCache != null) return _recitersCache!;
    final raw = await rootBundle.loadString(AppConstants.recitersAsset);
    final list = (jsonDecode(raw) as List)
        .map((e) => Reciter.fromJson(e as Map<String, dynamic>))
        .toList();
    return _recitersCache = list;
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final duasProvider = FutureProvider<List<Dua>>((ref) {
  return ref.watch(contentRepositoryProvider).loadDuas();
});

final duasByIdProvider = FutureProvider<Map<String, Dua>>((ref) async {
  final duas = await ref.watch(duasProvider.future);
  return {for (final d in duas) d.id: d};
});

final sessionsProvider = FutureProvider<List<RuqyahSession>>((ref) {
  return ref.watch(contentRepositoryProvider).loadSessions();
});

final adhkarProvider = FutureProvider<List<Dhikr>>((ref) {
  return ref.watch(contentRepositoryProvider).loadAdhkar();
});

final recitersProvider = FutureProvider<List<Reciter>>((ref) {
  return ref.watch(contentRepositoryProvider).loadReciters();
});

/// Duas filtered by category, derived from [duasProvider].
final duasByCategoryProvider =
    FutureProvider.family<List<Dua>, RuqyahCategory>((ref, category) async {
  final duas = await ref.watch(duasProvider.future);
  return duas.where((d) => d.category == category).toList();
});
