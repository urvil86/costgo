/// Settings — your name, your sport (the scoring language), the paper's tone,
/// and the privacy fine print. Pushed as a normal route with a back arrow.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../features/roasts/frank.dart';
import '../features/sports/sport_skin.dart';
import '../game/game_controller.dart';
import 'widgets.dart';

void openSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SettingsScreen()),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: NewsInk.paper,
      appBar: AppBar(
        backgroundColor: NewsInk.paper,
        foregroundColor: NewsInk.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('SETTINGS', style: News.anton(20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Text('YOUR NAME', style: News.kicker(10, color: NewsInk.red)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: settings.playerName,
            style: News.mono(14),
            decoration: InputDecoration(
              hintText: 'The byline on your scorecards',
              hintStyle: News.mono(12, color: NewsInk.grayFaint),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: NewsInk.black, width: 2),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: NewsInk.red, width: 2),
              ),
            ),
            onChanged: (v) =>
                notifier.update(settings.copyWith(playerName: v.trim())),
          ),
          const SizedBox(height: 22),
          Text('YOUR SPORT', style: News.kicker(10, color: NewsInk.red)),
          const SizedBox(height: 4),
          Text(
              'Sets the scoring language for future trips. Past trips keep '
              'the wording they were scored under.',
              style: News.mono(11, color: NewsInk.gray, height: 1.4)),
          const SizedBox(height: 10),
          for (final sport in SportSkin.all)
            GestureDetector(
              onTap: () =>
                  notifier.update(settings.copyWith(sportKey: sport.key)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: settings.sportKey == sport.key
                      ? NewsInk.mustard
                      : NewsInk.card,
                  border: Border.all(
                      color: settings.sportKey == sport.key
                          ? NewsInk.black
                          : NewsInk.ruleDark,
                      width: 2),
                ),
                child: Row(
                  children: [
                    Text(sport.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sport.label,
                              style: News.mono(12,
                                  weight: FontWeight.w700, spacing: 1)),
                          Text(
                              '${sport.parWord} · best: '
                              '${sport.verdicts.first} · worst: '
                              '${sport.verdicts.last}',
                              style:
                                  News.mono(10, color: NewsInk.gray)),
                        ],
                      ),
                    ),
                    if (settings.sportKey == sport.key)
                      const Icon(Icons.check_rounded, size: 20),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text('EDITORIAL TONE', style: News.kicker(10, color: NewsInk.red)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final tone in RoastTone.values) ...[
                Expanded(
                  child: InkButton(
                    onTap: () =>
                        notifier.update(settings.copyWith(tone: tone)),
                    color: settings.tone == tone
                        ? NewsInk.black
                        : Colors.transparent,
                    border: const Border.fromBorderSide(
                        BorderSide(color: NewsInk.black, width: 2)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(tone.name.toUpperCase(),
                        style: News.mono(11,
                            color: settings.tone == tone
                                ? NewsInk.paper
                                : NewsInk.black,
                            weight: FontWeight.w700,
                            spacing: 1)),
                  ),
                ),
                if (tone != RoastTone.values.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 26),
          Container(height: 2, color: NewsInk.black),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lock_rounded, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('PRIVACY', style: News.kicker(10)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
              'No account. No cloud. No analytics. Receipts are read on this '
              'phone and stay on this phone. The paper keeps your secrets. '
              'The paper keeps everything.',
              style: News.mono(11, color: NewsInk.gray, height: 1.5)),
          const SizedBox(height: 18),
          Text(
              'COST-GO v0.2 · UNAFFILIATED WITH COSTCO WHOLESALE. '
              'THE DAILY CART IS AN INDEPENDENT PAPER.',
              style: News.mono(8, color: NewsInk.grayFaint, spacing: 1)),
        ],
      ),
    );
  }
}
