import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_controller.dart';

/// Thin wrapper around the in-app purchase provider (RevenueCat).
///
/// The actual RevenueCat calls are intentionally isolated here so the rest of
/// the app depends only on a boolean entitlement. Wire [AppConstants.revenueCatApiKey]
/// and call [Purchases.configure] in main() before enabling real billing.
class PremiumController {
  PremiumController(this._ref);

  final Ref _ref;

  /// Restore previously purchased entitlements.
  Future<void> restore() async {
    // TODO: integrate RevenueCat:
    //   final info = await Purchases.restorePurchases();
    //   final active = info.entitlements.active
    //       .containsKey(AppConstants.premiumEntitlementId);
    //   _ref.read(settingsControllerProvider.notifier).setPremium(active);
    debugPrint('restorePurchases() — wire RevenueCat before release.');
  }

  /// Purchase the Pro subscription.
  Future<void> subscribe() async {
    // TODO: integrate RevenueCat:
    //   final offerings = await Purchases.getOfferings();
    //   final pkg = offerings.current?.availablePackages.first;
    //   final info = await Purchases.purchasePackage(pkg!);
    //   final active = info.entitlements.active
    //       .containsKey(AppConstants.premiumEntitlementId);
    //   _ref.read(settingsControllerProvider.notifier).setPremium(active);

    // Demo fallback so the flow is testable without store credentials.
    _ref.read(settingsControllerProvider.notifier).setPremium(true);
  }
}

final premiumControllerProvider = Provider<PremiumController>((ref) {
  return PremiumController(ref);
});
