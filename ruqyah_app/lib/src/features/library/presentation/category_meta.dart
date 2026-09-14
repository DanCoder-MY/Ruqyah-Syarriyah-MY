import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../domain/dua.dart';

/// Presentation metadata (label + icon) for each category.
class CategoryMeta {
  const CategoryMeta(this.category, this.icon);
  final RuqyahCategory category;
  final IconData icon;

  String label(AppLocalizations l10n) => switch (category) {
        RuqyahCategory.protection => l10n.categoryProtection,
        RuqyahCategory.healing => l10n.categoryHealing,
        RuqyahCategory.evilEye => l10n.categoryEvilEye,
        RuqyahCategory.sihr => l10n.categorySihr,
        RuqyahCategory.anxiety => l10n.categoryAnxiety,
        RuqyahCategory.sleep => l10n.categorySleep,
        RuqyahCategory.waking => l10n.categoryWaking,
      };

  static const List<CategoryMeta> all = [
    CategoryMeta(RuqyahCategory.protection, Icons.shield_rounded),
    CategoryMeta(RuqyahCategory.healing, Icons.healing_rounded),
    CategoryMeta(RuqyahCategory.evilEye, Icons.remove_red_eye_rounded),
    CategoryMeta(RuqyahCategory.sihr, Icons.auto_fix_off_rounded),
    CategoryMeta(RuqyahCategory.anxiety, Icons.self_improvement_rounded),
    CategoryMeta(RuqyahCategory.sleep, Icons.nightlight_round),
    CategoryMeta(RuqyahCategory.waking, Icons.wb_twilight_rounded),
  ];

  static CategoryMeta of(RuqyahCategory category) =>
      all.firstWhere((m) => m.category == category);
}
