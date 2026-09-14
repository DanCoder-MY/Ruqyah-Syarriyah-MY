import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../library/domain/dua.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/session.dart';

class SessionPlayerScreen extends ConsumerWidget {
  const SessionPlayerScreen({required this.sessionId, this.session, super.key});

  final String sessionId;
  final RuqyahSession? session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (session != null) return _Flow(session: session!);
    final sessionsAsync = ref.watch(sessionsProvider);
    return sessionsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (sessions) {
        final found = sessions.where((s) => s.id == sessionId).firstOrNull;
        if (found == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        return _Flow(session: found);
      },
    );
  }
}

class _Flow extends ConsumerStatefulWidget {
  const _Flow({required this.session});
  final RuqyahSession session;

  @override
  ConsumerState<_Flow> createState() => _FlowState();
}

class _FlowState extends ConsumerState<_Flow> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final settings = ref.watch(settingsControllerProvider);
    final byId = ref.watch(duasByIdProvider);
    final steps = widget.session.steps;
    final total = steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.titleFor(lang)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / total),
        ),
      ),
      body: byId.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (map) {
          final step = steps[_index];
          final dua = map[step.duaId];
          if (dua == null) return const Center(child: Text('Missing entry'));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.sessionStep(_index + 1, total),
                        style: theme.textTheme.titleMedium),
                    Chip(
                      avatar: const Icon(Icons.repeat_rounded, size: 16),
                      label: Text(l10n.adhkarRepeat(step.repeat)),
                    ),
                  ],
                ),
              ),
              Expanded(child: _StepBody(dua: dua, lang: lang, settings: settings)),
              _NavBar(
                index: _index,
                total: total,
                onPrev: _index > 0 ? () => setState(() => _index--) : null,
                onNext: () {
                  HapticFeedback.selectionClick();
                  if (_index < total - 1) {
                    setState(() => _index++);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.dua, required this.lang, required this.settings});

  final Dua dua;
  final String lang;
  final dynamic settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        Text(dua.titleFor(lang), style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
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
              scale: settings.arabicScale as double,
            ),
          ),
        ),
        if (settings.showTransliteration as bool &&
            dua.transliteration.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(dua.transliteration,
              style: AppTypography.transliteration(
                  color: theme.colorScheme.secondary)),
        ],
        if (settings.showTranslation as bool) ...[
          const SizedBox(height: 16),
          Text(dua.translationFor(lang), style: theme.textTheme.bodyLarge),
        ],
        const SizedBox(height: 16),
        Text('${l10n.source}: ${dua.source}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.primary)),
      ],
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = index == total - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNext,
                icon: Icon(isLast
                    ? Icons.check_rounded
                    : Icons.chevron_right_rounded),
                label: Text(isLast ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
