/// THE DAILY CART — SPECIAL EDITION. The verdict: headline, over/under
/// stamp, verdict stamp, exhibits, Frank's quote, barcode, mulligan,
/// sign card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../features/scoring/verdict_engine.dart';
import '../game/game_controller.dart';
import 'widgets.dart';

class RoastScreen extends ConsumerWidget {
  const RoastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final score = game.score;
    if (score == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final v = score.verdict;
    final vColor = verdictColor(v.color);
    final over = score.over;
    final canMulligan = !game.mulliganUsed && score.mulliganTarget != null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: NewsInk.black, width: 3)),
                ),
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                        child: Text('THE DAILY CART', style: News.anton(22))),
                    Text('SPECIAL EDITION',
                        style: News.mono(10, weight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final discard = await confirmDialog(
                          context,
                          title: 'TOSS THIS EDITION?',
                          body: 'The round won\'t be scored or saved. '
                              'The presses stop. Nobody reads about the '
                              'kayak.',
                          confirmLabel: 'TOSS IT',
                        );
                        if (discard) ctrl.discardVerdict();
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Icon(Icons.close_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: NewsInk.mustard,
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: FutureBuilder<int>(
                  future: ctrl.nextHole(),
                  builder: (context, snap) => Text(
                      'BREAKING · ${score.sport.tripWord} '
                      '#${snap.data ?? '—'} · FINAL SCORE',
                      style: News.kicker(11)),
                ),
              ),
              const SizedBox(height: 12),
              Text(v.headline.toUpperCase(),
                  style: News.anton(36, height: 1.03)),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Text(
                        _story(game, score,
                            ref.watch(settingsProvider).playerName),
                        style: News.mono(12, color: NewsInk.body, height: 1.55),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Stamp(
                      angleDegrees: 2,
                      child: Container(
                        width: 116,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 10),
                        color: vColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(over >= 0 ? 'OVER PAR' : 'UNDER PAR',
                                style: News.mono(9,
                                    color: NewsInk.paper, spacing: 2)),
                            Text(
                                '${over >= 0 ? '+\$' : '−\$'}'
                                '${over.abs().toStringAsFixed(0)}',
                                style: News.anton(30, color: NewsInk.paper)),
                            Text('VS ${score.sport.parWord} \$${score.par}',
                                style: News.mono(9,
                                    color: NewsInk.paper, spacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Stamp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: vColor, width: 4)),
                    child: Text(v.name,
                        style: News.mono(26,
                            color: vColor,
                            weight: FontWeight.w700,
                            spacing: 3)),
                  ),
                ),
              ),
              if (score.impulses.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: NewsInk.black, width: 2),
                      bottom: BorderSide(color: NewsInk.black, width: 2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXHIBITS ENTERED INTO EVIDENCE:',
                          style: News.kicker(10)),
                      const SizedBox(height: 6),
                      for (final e in score.impulses)
                        Builder(builder: (context) {
                          final struck = score.mulliganUsed &&
                              identical(e, score.mulliganTarget);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.name,
                                    style: News.mono(12,
                                            color: struck
                                                ? NewsInk.grayFaint
                                                : NewsInk.black)
                                        .copyWith(
                                            decoration: struck
                                                ? TextDecoration.lineThrough
                                                : null)),
                                Text('\$${money(e.price)}',
                                    style: News.mono(12,
                                            color: struck
                                                ? NewsInk.grayFaint
                                                : NewsInk.black,
                                            weight: FontWeight.w700)
                                        .copyWith(
                                            decoration: struck
                                                ? TextDecoration.lineThrough
                                                : null)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text('"${game.frankQuote}"', style: News.serifQuote(17)),
              const SizedBox(height: 4),
              Builder(builder: (context) {
                final name = ref.watch(settingsProvider).playerName;
                return Text(
                    name.isEmpty
                        ? '— SENIOR WAREHOUSE CORRESPONDENT'
                        : '— ${name.toUpperCase()}, '
                            'SENIOR WAREHOUSE CORRESPONDENT',
                    style: News.kicker(10, color: NewsInk.red));
              }),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  v.name.replaceAll(' ', ''),
                  style: News.barcode(40),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: NewsInk.card,
            border: Border(top: BorderSide(color: NewsInk.black, width: 3)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Row(
                children: [
                  if (canMulligan) ...[
                    Expanded(
                      child: InkButton(
                        onTap: ctrl.useMulligan,
                        pressedColor: NewsInk.cardDim,
                        border: const Border.fromBorderSide(
                            BorderSide(color: NewsInk.black, width: 2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(score.sport.mulliganLabel,
                            style: News.anton(14, spacing: 1)),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: InkButton(
                      onTap: () => ctrl.signCard(),
                      color: NewsInk.black,
                      pressedColor: NewsInk.blackHover,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text('SIGN CARD',
                          style:
                              News.anton(14, color: NewsInk.paper, spacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _story(GameState game, TripScore score, String playerName) {
    final listCount = score.items.where((i) => !i.impulse).length;
    final subject =
        playerName.isEmpty ? 'The subject' : 'The subject, "$playerName,"';
    return '$subject entered with a list and exited with '
        '${score.items.length} item${score.items.length == 1 ? '' : 's'} '
        '($listCount planned, ${score.impulses.length} confessed'
        '${score.hotDog ? ', plus one hot dog, which does not count' : ''}). '
        'Total damage: \$${money(score.finalTotal)} against '
        '${score.sport.parWord.toLowerCase()} of \$${score.par}.'
        '${score.mulliganUsed ? ' One exhibit was stricken from the record '
            'on appeal.' : ''}';
  }
}
