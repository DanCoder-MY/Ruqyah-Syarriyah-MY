# Ruqyah Syar'iyyah — Pro Edition (Flutter)

Authentic Qur'an & Sunnah based self-healing and spiritual protection app.
Every entry cites a verifiable source (Qur'an ayah or authenticated hadith).

> This is a full Flutter source project. It was authored in an environment that
> cannot compile APKs, so you build it locally with the standard Flutter toolchain.

## Stack

| Concern            | Choice                                             |
| ------------------ | -------------------------------------------------- |
| State management   | Riverpod (`flutter_riverpod`)                      |
| Architecture       | Clean-ish, feature-first (`presentation` / `domain` / `application` / `data`) |
| Routing            | `go_router` (typed `AppRoute` enum, StatefulShell) |
| Audio              | `just_audio` + `just_audio_background` + `audio_service` |
| Local storage      | `hive` (settings, bookmarks, progress, downloads)  |
| Localization       | `flutter_localizations` + ARB (`en`, `ar`, `ms`), full RTL |
| Monetization       | RevenueCat (`purchases_flutter`) — wire keys before release |

## Project layout

```
lib/
  main.dart                     # bootstrap: Hive, background audio, ProviderScope
  src/
    app.dart                    # MaterialApp.router, theme + locale wiring
    core/
      constants/                # app + storage keys, CDN base, RC keys
      data/content_repository.dart  # loads bundled JSON, exposes Riverpod providers
      l10n/arb/                 # app_en.arb, app_ar.arb, app_ms.arb
      router/                   # go_router config + AppRoute enum
      theme/                    # colors, typography, light/dark themes
    features/
      home/ library/ sessions/ adhkar/ player/
      bookmarks/ premium/ settings/ onboarding/ shell/
assets/
  content/  duas.json sessions.json adhkar.json reciters.json
  fonts/    (add AmiriQuran + Amiri TTFs — see below)
  audio/    (add recitation audio or serve via CDN)
```

## Prerequisites

1. Flutter SDK `>=3.24` (Dart `>=3.4`).
2. Add the required fonts to `assets/fonts/` (referenced in `pubspec.yaml`):
   - `AmiriQuran-Regular.ttf` (Uthmani-friendly, for verses)
   - `Amiri-Regular.ttf`, `Amiri-Bold.ttf`
   Both are SIL OFL licensed. Verify licensing for any Mushaf font (e.g. KFGQPC) before shipping.
3. Add a launcher icon and any recitation audio you have rights to.

## Setup & run

```bash
flutter pub get

# Generate localization code from the ARB files (required — creates
# lib/src/core/l10n/gen/app_localizations.dart):
flutter gen-l10n

flutter run
```

## Build release APK / AAB

```bash
# APK (sideload / testing)
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# With RevenueCat key injected at build time
flutter build apk --release --dart-define=RC_API_KEY=your_public_sdk_key
```

Configure signing in `android/app/build.gradle` (`signingConfigs`) with your
keystore before distributing.

## Content authenticity workflow

- All content ships bundled in `assets/content/*.json` so the app works offline
  on first launch.
- **Every entry MUST keep its `source` field** (e.g. `"Qur'an 2:255"`,
  `"Sahih al-Bukhari 5675"`). The UI renders it everywhere the entry appears.
- Arabic must match the Mushaf exactly. Have a qualified reviewer verify text
  and hadith gradings before each release.
- To add an entry: append an object to `duas.json` (see schema in
  `lib/src/features/library/domain/dua.dart`) with `title`, `arabic`,
  `transliteration`, `translations` (`en`/`ar`/`ms`), `source`, `category`,
  optional `repeat`, and `audioAsset`/`audioUrl`.

## Audio packs

- Bundle small audio in `assets/audio/` and reference via `audioAsset`, or
- Serve downloadable packs from a CDN (`AppConstants.audioCdnBase`) referenced
  via `audioUrl`. Offline downloads are tracked in the `downloads` Hive box.

## Monetization (RevenueCat)

`lib/src/features/premium/application/premium_controller.dart` isolates all IAP
logic behind a boolean entitlement. Before release:

1. Create products/entitlement (`pro`) in RevenueCat + App Store / Play Console.
2. `Purchases.configure(...)` in `main()` with the platform SDK key.
3. Uncomment the real `restore()` / `subscribe()` bodies.

The current demo `subscribe()` flips the local flag so the flow is testable
without store credentials.

## Compliance

- Medical + authenticity disclaimers live in the onboarding/disclaimer screen
  and Settings. Keep them. Position the app as spiritual practice, **not** a
  medical treatment — avoid any "guaranteed cure" language.
- Data collection is minimal and local-first (Hive). Add a privacy policy
  before store submission.

## Suggested next steps

- Wire `flutter gen-l10n` into CI (GitHub Actions / Codemagic): analyze → test → build.
- Add golden tests for Arabic rendering.
- Cloud backup/sync of favorites + settings for the Pro tier.
- Reciter pack management UI on top of the existing `downloads` box.
```
