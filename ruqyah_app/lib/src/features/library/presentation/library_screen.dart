import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/dua.dart';
import 'category_meta.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _query = '';
  RuqyahCategory? _category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final duasAsync = ref.watch(duasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: duasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (duas) {
          final filtered = duas.where((d) {
            final matchesCategory = _category == null || d.category == _category;
            final q = _query.trim().toLowerCase();
            final matchesQuery = q.isEmpty ||
                d.titleFor(lang).toLowerCase().contains(q) ||
                d.translationFor(lang).toLowerCase().contains(q) ||
                d.source.toLowerCase().contains(q);
            return matchesCategory && matchesQuery;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SearchBar(
                    hintText: l10n.librarySearchHint,
                    leading: const Icon(Icons.search_rounded),
                    onChanged: (v) => setState(() => _query = v),
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _CategoryChips(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              )),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) =>
                      _DuaCard(dua: filtered[i], lang: lang),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final RuqyahCategory? selected;
  final ValueChanged<RuqyahCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final meta in CategoryMeta.all)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(meta.icon, size: 18),
                label: Text(meta.label(l10n)),
                selected: selected == meta.category,
                onSelected: (_) => onSelected(
                  selected == meta.category ? null : meta.category,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  const _DuaCard({required this.dua, required this.lang});

  final Dua dua;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final meta = CategoryMeta.of(dua.category);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed('duaDetail',
            pathParameters: {'id': dua.id}, extra: dua),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(meta.icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(dua.titleFor(lang),
                        style: theme.textTheme.titleMedium),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                dua.arabic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 22,
                  height: 1.9,
                ),
              ),
              const SizedBox(height: 10),
              Text('${l10n.source}: ${dua.source}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
