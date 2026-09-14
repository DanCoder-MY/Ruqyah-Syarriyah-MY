import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/content_repository.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.homeGreeting, style: theme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(l10n.homeSubtitle,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.shield_rounded,
                    label: l10n.homeQuickProtection,
                    onTap: () => context.goNamed('library'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.brightness_medium_rounded,
                    label: l10n.homeMorningEvening,
                    onTap: () => context.goNamed('adhkar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.sessionsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (sessions) => Column(
                children: [
                  for (final s in sessions.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.play_circle_fill_rounded,
                              color: theme.colorScheme.primary, size: 36),
                          title: Text(s.titleFor(lang)),
                          subtitle: Text(s.descriptionFor(lang),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.goNamed('sessions'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _PremiumBanner(),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isPremium = ref.watch(settingsControllerProvider).isPremium;
    if (isPremium) return const SizedBox.shrink();
    return Card(
      color: theme.colorScheme.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed('paywall'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Text(l10n.premiumTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white)),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
