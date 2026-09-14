import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/adhkar/presentation/adhkar_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/domain/dua.dart';
import '../../features/library/presentation/dua_detail_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/onboarding/presentation/disclaimer_screen.dart';
import '../../features/player/presentation/player_screen.dart';
import '../../features/premium/presentation/paywall_screen.dart';
import '../../features/sessions/domain/session.dart';
import '../../features/sessions/presentation/session_player_screen.dart';
import '../../features/sessions/presentation/sessions_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

part 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      GoRoute(
        path: AppRoute.disclaimer.path,
        name: AppRoute.disclaimer.name,
        builder: (context, state) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: AppRoute.paywall.path,
        name: AppRoute.paywall.name,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoute.player.path,
        name: AppRoute.player.name,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: '/dua/:id',
        name: AppRoute.duaDetail.name,
        builder: (context, state) {
          final dua = state.extra as Dua?;
          return DuaDetailScreen(duaId: state.pathParameters['id']!, dua: dua);
        },
      ),
      GoRoute(
        path: '/session/:id',
        name: AppRoute.sessionPlayer.name,
        builder: (context, state) {
          final session = state.extra as RuqyahSession?;
          return SessionPlayerScreen(
            sessionId: state.pathParameters['id']!,
            session: session,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.home.path,
              name: AppRoute.home.name,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.library.path,
              name: AppRoute.library.name,
              builder: (context, state) => const LibraryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.sessions.path,
              name: AppRoute.sessions.name,
              builder: (context, state) => const SessionsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.adhkar.path,
              name: AppRoute.adhkar.name,
              builder: (context, state) => const AdhkarScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoute.settings.path,
              name: AppRoute.settings.name,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'bookmarks',
                  name: AppRoute.bookmarks.name,
                  builder: (context, state) => const BookmarksScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
