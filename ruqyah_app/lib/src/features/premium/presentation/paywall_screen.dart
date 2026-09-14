import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../application/premium_controller.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isPremium = ref.watch(settingsControllerProvider).isPremium;
    final controller = ref.read(premiumControllerProvider);

    final features = [
      (Icons.record_voice_over_rounded, l10n.premiumFeatureReciters),
      (Icons.high_quality_rounded, l10n.premiumFeatureHd),
      (Icons.build_rounded, l10n.premiumFeatureBuilder),
      (Icons.insights_rounded, l10n.premiumFeatureAnalytics),
      (Icons.cloud_sync_rounded, l10n.premiumFeatureSync),
      (Icons.block_rounded, l10n.premiumFeatureAds),
    ];

    return Scaffold(
      appBar: AppBar(leading: const CloseButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                theme.colorScheme.tertiary,
                theme.colorScheme.primary,
              ]),
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                size: 44, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(l10n.premiumTitle,
              style: theme.textTheme.displaySmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(l10n.premiumSubtitle,
              style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          for (final (icon, label) in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(label, style: theme.textTheme.bodyLarge)),
                  Icon(Icons.check_circle_rounded,
                      color: theme.colorScheme.primary),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (isPremium)
            Card(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(l10n.premiumActive,
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            )
          else ...[
            FilledButton(
              onPressed: () async {
                await controller.subscribe();
                if (context.mounted) Navigator.of(context).maybePop();
              },
              child: Text(l10n.premiumSubscribe),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.restore,
              child: Text(l10n.premiumRestore),
            ),
          ],
        ],
      ),
    );
  }
}
