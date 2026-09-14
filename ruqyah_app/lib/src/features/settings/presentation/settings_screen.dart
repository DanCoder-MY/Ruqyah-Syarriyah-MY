import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(l10n.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.settingsThemeSystem)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.settingsThemeLight)),
                ButtonSegment(
                    value: ThemeMode.dark, label: Text(l10n.settingsThemeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => controller.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String?>(
              value: settings.locale?.languageCode,
              hint: Text(l10n.settingsThemeSystem),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: null, child: Text('System')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'ms', child: Text('Bahasa Melayu')),
              ],
              onChanged: (v) =>
                  controller.setLocale(v == null ? null : Locale(v)),
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsReading),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.format_size_rounded),
                Expanded(
                  child: Slider(
                    value: settings.arabicScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    label: '${(settings.arabicScale * 100).round()}%',
                    onChanged: controller.setArabicScale,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.abc_rounded),
            title: Text(l10n.settingsTransliteration),
            value: settings.showTransliteration,
            onChanged: controller.setShowTransliteration,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.translate_rounded),
            title: Text(l10n.settingsTranslation),
            value: settings.showTranslation,
            onChanged: controller.setShowTranslation,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.workspace_premium_rounded,
                color: theme.colorScheme.tertiary),
            title: Text(l10n.settingsPremium),
            subtitle: Text(settings.isPremium ? l10n.premiumActive : ''),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed('paywall'),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_rounded),
            title: Text(l10n.bookmarksTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.goNamed('bookmarks'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.settingsDisclaimer),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed('disclaimer'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title.toUpperCase(),
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1)),
    );
  }
}
