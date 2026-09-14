part of 'app_router.dart';

enum AppRoute {
  home('/home'),
  library('/library'),
  sessions('/sessions'),
  adhkar('/adhkar'),
  settings('/settings'),
  bookmarks('bookmarks'),
  duaDetail('/dua'),
  sessionPlayer('/session'),
  player('/player'),
  paywall('/paywall'),
  disclaimer('/disclaimer');

  const AppRoute(this.path);
  final String path;
}
