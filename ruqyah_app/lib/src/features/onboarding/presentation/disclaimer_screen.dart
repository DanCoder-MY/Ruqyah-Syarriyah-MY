import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final canPop = context.canPop();

    return Scaffold(
      appBar: AppBar(
        leading: canPop ? const BackButton() : null,
        title: Text(l10n.settingsDisclaimer),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.health_and_safety_rounded,
              size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.medicalDisclaimerTitle,
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(l10n.medicalDisclaimerBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.verified_rounded,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.authenticityNote,
                        style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (!canPop)
            FilledButton(
              onPressed: () => context.goNamed('home'),
              child: Text(l10n.agreeContinue),
            ),
        ],
      ),
    );
  }
}
