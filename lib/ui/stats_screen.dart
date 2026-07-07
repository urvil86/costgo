/// STATS tab — THE SPORTS PAGE. Rating, season damage, the strokes chart,
/// the Hall of Shame. Settings via the gear.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../game/game_controller.dart';
import 'settings_screen.dart';
import 'widgets.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ledger = ref.watch(ledgerProvider).valueOrNull ?? [];
    final sport = settings.sport;

    final seasonTotal = ledger.fold(0.0, (s, e) => s + e.total).round();
    final maxStrokes = ledger.isEmpty
        ? 1
        : ledger.map((e) => e.strokes.abs()).reduce(max).clamp(1, 99);
    final bars = ledger.take(8).toList().reversed.toList();
    final shame = ledger
        .where((e) => e.strokes > 0 && e.quote.isNotEmpty)
        .take(5)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      children: [
        Container(
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: NewsInk.black, width: 3)),
          ),
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: Text('THE SPORTS PAGE', style: News.anton(26))),
              GestureDetector(
                onTap: () => openSettings(context),
                child: const Icon(Icons.settings_rounded, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                color: NewsInk.black,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text(sport.ratingLabel,
                        style:
                            News.mono(9, color: NewsInk.mustard, spacing: 2)),
                    Text(settings.rating.toStringAsFixed(1),
                        style: News.anton(38, color: NewsInk.paper)),
                    Text('LOWER IS BETTER',
                        style: News.mono(7,
                            color: NewsInk.grayFaint, spacing: 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PaperCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Text('SEASON DAMAGE',
                        style: News.mono(9, color: NewsInk.red, spacing: 2)),
                    Text('\$$seasonTotal', style: News.anton(38)),
                    Text('TOTAL SPENT, ALL TRIPS',
                        style: News.mono(7,
                            color: NewsInk.grayFaint, spacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(sport.chartLabel, style: News.kicker(10)),
        const SizedBox(height: 8),
        Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: NewsInk.black, width: 2)),
          ),
          child: bars.isEmpty
              ? Center(
                  child: Text('NO TRIPS SCORED YET',
                      style: News.mono(10,
                          color: NewsInk.grayFaint, spacing: 2)),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final e in bars) ...[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                e.strokes > 0
                                    ? '+${e.strokes}'
                                    : e.strokes == 0
                                        ? 'E'
                                        : '${e.strokes}',
                                style: News.mono(9,
                                    weight: FontWeight.w700,
                                    color: e.strokes > 0
                                        ? NewsInk.red
                                        : NewsInk.green)),
                            const SizedBox(height: 4),
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: Container(
                                height: max(
                                    6, 64 * e.strokes.abs() / maxStrokes),
                                color: e.strokes > 0
                                    ? NewsInk.red
                                    : NewsInk.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (e != bars.last) const SizedBox(width: 6),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Text(
            settings.playerName.isEmpty
                ? 'HALL OF SHAME'
                : "${settings.playerName.toUpperCase()}'S HALL OF SHAME",
            style: News.kicker(10)),
        const SizedBox(height: 8),
        if (shame.isEmpty)
          PaperCard(
            child: Text(
              'Empty. Either you are perfect or you have never been to '
              'the store. The editors suspect the latter.',
              style: News.mono(11, color: NewsInk.gray, height: 1.5),
            ),
          ),
        for (final e in shame)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PaperCard(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${e.quote}"', style: News.serifQuote(14)),
                  const SizedBox(height: 4),
                  Text('${e.tripWord} #${e.hole} · ${e.verdictName}',
                      style:
                          News.mono(9, color: NewsInk.gray, spacing: 2)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
