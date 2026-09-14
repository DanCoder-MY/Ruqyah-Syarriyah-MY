import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../application/bookmarks_controller.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final ids = ref.watch(bookmarksControllerProvider);
    final byId = ref.watch(duasByIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarksTitle)),
      body: byId.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (map) {
          final items =
              ids.map((id) => map[id]).whereType<dynamic>().toList();
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(l10n.bookmarksEmpty,
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final dua = items[i];
              return Card(
                child: ListTile(
                  title: Text(dua.titleFor(lang)),
                  subtitle: Text('${l10n.source}: ${dua.source}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_remove_rounded),
                    onPressed: () => ref
                        .read(bookmarksControllerProvider.notifier)
                        .toggle(dua.id),
                  ),
                  onTap: () => context.pushNamed('duaDetail',
                      pathParameters: {'id': dua.id}, extra: dua),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
