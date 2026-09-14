import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/dhikr.dart';

class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adhkarTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.adhkarMorning),
              Tab(text: l10n.adhkarEvening),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AdhkarList(time: AdhkarTime.morning),
            _AdhkarList(time: AdhkarTime.evening),
          ],
        ),
      ),
    );
  }
}

class _AdhkarList extends ConsumerWidget {
  const _AdhkarList({required this.time});
  final AdhkarTime time;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhkarAsync = ref.watch(adhkarProvider);
    final lang = ref.watch(languageCodeProvider);
    return adhkarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final items = all.where((d) => d.times.contains(time)).toList();
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _DhikrCounterCard(dhikr: items[i], lang: lang),
        );
      },
    );
  }
}

class _DhikrCounterCard extends ConsumerStatefulWidget {
  const _DhikrCounterCard({required this.dhikr, required this.lang});
  final Dhikr dhikr;
  final String lang;

  @override
  ConsumerState<_DhikrCounterCard> createState() => _DhikrCounterCardState();
}

class _DhikrCounterCardState extends ConsumerState<_DhikrCounterCard> {
  int _count = 0;

  bool get _done => _count >= widget.dhikr.repeat;

  void _increment() {
    if (_done) return;
    HapticFeedback.lightImpact();
    setState(() => _count++);
    if (_done) HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final d = widget.dhikr;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _increment,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: AppTypography.arabicVerse(
                  color: theme.colorScheme.onSurface,
                  scale: (settings.arabicScale * 0.7).clamp(0.7, 1.1),
                ),
              ),
              if (settings.showTranslation) ...[
                const SizedBox(height: 12),
                Text(d.translationFor(widget.lang),
                    style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              Text('${l10n.source}: ${d.source}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CounterRing(count: _count, total: d.repeat, done: _done),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _done ? l10n.adhkarCompleted : l10n.adhkarRepeat(d.repeat),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _done
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_count > 0)
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => setState(() => _count = 0),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterRing extends StatelessWidget {
  const _CounterRing({
    required this.count,
    required this.total,
    required this.done,
  });

  final int count;
  final int total;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: total == 0 ? 0 : count / total,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            strokeWidth: 4,
          ),
          Text(
            done ? '✓' : '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              color: done ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
