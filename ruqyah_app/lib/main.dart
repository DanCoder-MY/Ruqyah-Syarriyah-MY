import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'src/app.dart';
import 'src/core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background audio (lock-screen + notification controls).
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ruqyah.pro.audio',
    androidNotificationChannelName: 'Ruqyah Playback',
    androidNotificationOngoing: true,
  );

  // Local storage.
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>(AppConstants.settingsBox),
    Hive.openBox<dynamic>(AppConstants.bookmarksBox),
    Hive.openBox<dynamic>(AppConstants.progressBox),
    Hive.openBox<dynamic>(AppConstants.downloadsBox),
  ]);

  runApp(const ProviderScope(child: RuqyahApp()));
}
