import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../application/audio_controller.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(languageCodeProvider);
    final audio = ref.watch(audioControllerProvider);
    final controller = ref.read(audioControllerProvider.notifier);
    final dua = audio.dua;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playerNowPlaying),
        leading: const BackButton(),
      ),
      body: dua == null
          ? const Center(child: Text('—'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.graphic_eq_rounded,
                        size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Text(dua.titleFor(lang),
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('${l10n.source}: ${dua.source}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                  const Spacer(),
                  const _ProgressBar(),
                  const SizedBox(height: 12),
                  _TransportControls(),
                  const SizedBox(height: 16),
                  _OptionsRow(audio: audio, controller: controller),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playbackProgressProvider);
    final player = ref.read(audioControllerProvider.notifier).player;
    return progress.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (p) {
        final total = p.total.inMilliseconds == 0 ? 1 : p.total.inMilliseconds;
        final value = p.position.inMilliseconds.clamp(0, total).toDouble();
        return Column(
          children: [
            Slider(
              value: value,
              max: total.toDouble(),
              onChanged: (v) =>
                  player.seek(Duration(milliseconds: v.round())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(p.position)),
                  Text(_fmt(p.total)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _TransportControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(audioControllerProvider.notifier);
    final playing = ref.watch(playingStateProvider).value ?? false;
    final player = controller.player;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.replay_10_rounded),
          onPressed: () => player
              .seek(player.position - const Duration(seconds: 10)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.large(
          onPressed: controller.togglePlay,
          child: Icon(playing
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded),
        ),
        const SizedBox(width: 12),
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.forward_10_rounded),
          onPressed: () => player
              .seek(player.position + const Duration(seconds: 10)),
        ),
      ],
    );
  }
}

class _OptionsRow extends ConsumerWidget {
  const _OptionsRow({required this.audio, required this.controller});

  final AudioUiState audio;
  final AudioController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: Icon(
            audio.loopCount == 0 ? Icons.repeat_one_rounded : Icons.repeat_rounded,
            color: audio.loopCount == 0 ? theme.colorScheme.primary : null,
          ),
          label: Text(l10n.playerLoop),
          onPressed: controller.cycleLoop,
        ),
        ActionChip(
          avatar: const Icon(Icons.speed_rounded),
          label: Text('${l10n.playerSpeed} ${audio.speed}x'),
          onPressed: () => _pickSpeed(context, controller),
        ),
        ActionChip(
          avatar: Icon(
            Icons.repeat_on_rounded,
            color: audio.hasAbRepeat ? theme.colorScheme.primary : null,
          ),
          label: Text(l10n.playerAbRepeat),
          onPressed: () {
            if (audio.hasAbRepeat) {
              controller.clearAb();
            } else {
              controller.markAbPoint(controller.player.position);
            }
          },
        ),
        ActionChip(
          avatar: Icon(
            Icons.bedtime_rounded,
            color: audio.sleepTimerEnd != null ? theme.colorScheme.primary : null,
          ),
          label: Text(l10n.playerSleepTimer),
          onPressed: () => _pickSleep(context, controller),
        ),
      ],
    );
  }

  void _pickSpeed(BuildContext context, AudioController controller) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in const [0.75, 1.0, 1.25, 1.5, 2.0])
              ListTile(
                title: Text('${s}x'),
                onTap: () {
                  controller.setSpeed(s);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickSleep(BuildContext context, AudioController controller) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final m in const [5, 10, 15, 30, 60])
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: Text('$m min'),
                onTap: () {
                  controller.setSleepTimer(Duration(minutes: m));
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Off'),
              onTap: () {
                controller.setSleepTimer(null);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
