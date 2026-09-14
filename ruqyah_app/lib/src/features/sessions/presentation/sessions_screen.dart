import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/session.dart';

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final sessionsAsync = ref.watch(sessionsProvider);
    final isPremium = ref.watch(settingsControllerProvider).isPremium;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sessionsTitle)),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (sessions) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _SessionCard(
            session: sessions[i],
            lang: lang,
            locked: sessions[i].isPremium && !isPremium,
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.lang,
    required this.locked,
  });

  final RuqyahSession session;
  final String lang;
  final bool locked;

  IconData get _icon => switch (session.icon) {
        'sun' => Icons.wb_sunny_rounded,
        'moon' => Icons.nightlight_round,
        'heart' => Icons.favorite_rounded,
        _ => Icons.shield_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (locked) {
            context.pushNamed('paywall');
          } else {
            context.pushNamed('sessionPlayer',
                pathParameters: {'id': session.id}, extra: session);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(session.titleFor(lang),
                              style: theme.textTheme.titleMedium),
                        ),
                        if (session.isPremium) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.workspace_premium_rounded,
                              size: 18, color: theme.colorScheme.tertiary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(session.descriptionFor(lang),
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('${session.steps.length} steps',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              Icon(locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
