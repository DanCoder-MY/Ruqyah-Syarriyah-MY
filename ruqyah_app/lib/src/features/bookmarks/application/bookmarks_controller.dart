import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';

/// Stores bookmarked du'a ids. Persisted locally via Hive.
class BookmarksController extends StateNotifier<Set<String>> {
  BookmarksController(this._box)
      : super({...(_box.get('ids', defaultValue: <String>[]) as List).cast<String>()});

  final Box<dynamic> _box;

  bool isBookmarked(String id) => state.contains(id);

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    _box.put('ids', next.toList());
  }
}

final bookmarksBoxProvider = Provider<Box<dynamic>>((ref) {
  return Hive.box<dynamic>(AppConstants.bookmarksBox);
});

final bookmarksControllerProvider =
    StateNotifierProvider<BookmarksController, Set<String>>((ref) {
  return BookmarksController(ref.watch(bookmarksBoxProvider));
});
