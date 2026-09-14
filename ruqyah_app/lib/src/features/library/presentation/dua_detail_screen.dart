import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../bookmarks/application/bookmarks_controller.dart';
import '../../player/application/audio_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/dua.dart';

class DuaDetailScreen extends ConsumerWidget {
  const DuaDetailScreen({required this.duaId, this.dua, super.key});

  final String duaId;
  final Dua? dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dua != null) return _Content(dua: dua!);
    final byId = ref.watch(duasByIdProvider);
    return byId.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (map) {
        final found = map[duaId];
        if (found == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        return _Content(dua: found);
      },
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final settings = ref.watch(settingsControllerProvider);
    final bookmarks = ref.watch(bookmarksControllerProvider);
    final isBookmarked = bookmarks.contains(dua.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(dua.titleFor(lang)),
        actions: [
          IconButton(
            icon: Icon(isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded),
            onPressed: () =>
                ref.read(bookmarksControllerProvider.notifier).toggle(dua.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          if (dua.repeat > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Chip(
                  avatar: const Icon(Icons.repeat_rounded, size: 18),
                  label: Text(l10n.adhkarRepeat(dua.repeat)),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dua.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTypography.arabicVerse(
                color: theme.colorScheme.onSurface,
                scale: settings.arabicScale,
              ),
            ),
          ),
          if (settings.showTransliteration && dua.transliteration.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(dua.transliteration,
                style: AppTypography.transliteration(
                    color: theme.colorScheme.secondary)),
          ],
          if (settings.showTranslation) ...[
            const SizedBox(height: 20),
            Text(dua.translationFor(lang), style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          _SourceBlock(dua: dua),
        ],
      ),
      bottomSheet: _PlayBar(dua: dua),
    );
  }
}

class _SourceBlock extends StatelessWidget {
  const _SourceBlock({required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_rounded,
                size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('${l10n.source}: ${dua.source}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
        if (dua.reference != null) ...[
          const SizedBox(height: 8),
          Text(dua.reference!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ],
    );
  }
}

class _PlayBar extends ConsumerWidget {
  const _PlayBar({required this.dua});

  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasAudio = dua.audioAsset != null || dua.audioUrl != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: hasAudio
              ? () => ref
                  .read(audioControllerProvider.notifier)
                  .playDua(dua, context)
              : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(hasAudio ? l10n.playerNowPlaying : '—'),
        ),
      ),
    );
  }
}
