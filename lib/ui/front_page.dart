/// FRONT PAGE tab — the newspaper. Masthead, ticker, last edition, trip
/// ledger. Pure reward surface: the action lives on THE LIST tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../data/db/database.dart';
import '../game/game_controller.dart';
import 'settings_screen.dart';
import 'widgets.dart';

class FrontPage extends ConsumerWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final ledger = ref.watch(ledgerProvider).valueOrNull ?? [];
    final last = ledger.isEmpty ? null : ledger.first;
    final sport = settings.sport;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      children: [
        // Masthead
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: NewsInk.black, width: 3)),
          ),
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text('THE DAILY CART',
                    style: News.anton(26, spacing: 0.5)),
              ),
              Text('COST-GO ED. · 25¢',
                  style: News.mono(10, weight: FontWeight.w700)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => openSettings(context),
                child: const Icon(Icons.settings_rounded, size: 20),
              ),
            ],
          ),
        ),
        // Ticker
        Container(
          color: NewsInk.mustard,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${sport.ratingLabel} '
                  '${settings.rating.toStringAsFixed(1)}',
                  style: News.kicker(11)),
              Text(_streakLabel(ledger), style: News.kicker(11)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (last == null) ...[
          // New reader orientation.
          Text('HOW THIS PAPER WORKS',
              style: News.kicker(10, color: NewsInk.red)),
          const SizedBox(height: 4),
          Text('NO NEWS IS BAD NEWS',
              style: News.anton(30, height: 1.05)),
          const SizedBox(height: 8),
          Text(
              'Every Costco trip you score becomes a headline here — the '
              'triumphs and the ${sport.verdicts.last.toLowerCase()}s. '
              'Build your list on THE LIST tab, shop, scan the receipt, '
              'and the paper files the story.',
              style: News.mono(12, color: NewsInk.body, height: 1.5)),
          const SizedBox(height: 16),
          PaperCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THE RULES', style: News.kicker(10)),
                const SizedBox(height: 8),
                Text(
                    '· Your budget is ${sport.parWord.toLowerCase()}. '
                    'Stay under it.\n'
                    '· Impulse buys get named in print.\n'
                    '· One ${sport.mulliganLabel.toLowerCase()} per trip.\n'
                    '· The \$1.50 hot dog never counts. House rule.',
                    style: News.mono(12, height: 1.7)),
              ],
            ),
          ),
        ] else ...[
          Text('LAST EDITION', style: News.kicker(10, color: NewsInk.red)),
          const SizedBox(height: 4),
          Text(last.headline.toUpperCase(),
              style: News.anton(30, height: 1.05)),
          const SizedBox(height: 8),
          Text(
            '${_cap(last.tripWord)} #${last.hole} · shot '
            '\$${money(last.total)} against '
            '${last.parWord.toLowerCase()} \$${last.par}. ${last.quote}',
            style: News.mono(12, color: NewsInk.body, height: 1.5),
          ),
        ],
        const _DashedRule(),
        Text('TRIP LEDGER — SEASON 1', style: News.kicker(10)),
        const SizedBox(height: 8),
        if (ledger.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('NO ROUNDS ON RECORD. THE PRESSES ARE WAITING.',
                style: News.mono(10, color: NewsInk.grayFaint, spacing: 1)),
          ),
        for (final (i, h) in ledger.take(12).indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PrintIn(index: i, child: _LedgerRow(entry: h)),
          ),
      ],
    );
  }

  String _streakLabel(List<LedgerEntry> ledger) {
    var streak = 0;
    for (final e in ledger) {
      if (e.strokes <= 0) {
        streak++;
      } else {
        break;
      }
    }
    if (ledger.isEmpty) return 'STREAK: —';
    return streak > 0
        ? 'STREAK: $streak CLEAN TRIP${streak == 1 ? '' : 'S'}'
        : 'STREAK: 0. OBVIOUSLY.';
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0] + s.substring(1).toLowerCase();
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = entry.strokes > 0
        ? NewsInk.red
        : entry.strokes < 0
            ? NewsInk.green
            : NewsInk.black;
    return PaperCard(
      child: Row(
        children: [
          SizedBox(
              width: 44,
              child: Text('#${entry.hole}', style: News.anton(15))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                  text: '\$${money(entry.total)} ',
                  style: News.mono(12, weight: FontWeight.w700),
                  children: [
                    TextSpan(
                        text:
                            '/ ${entry.parWord.toLowerCase()} ${entry.par}',
                        style: News.mono(12, color: NewsInk.gray)),
                  ],
                )),
                Text(newsDate(entry.scoredAt),
                    style: News.mono(10, color: NewsInk.gray)),
              ],
            ),
          ),
          Transform.rotate(
            angle: -4 * 3.14159 / 180,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration:
                  BoxDecoration(border: Border.all(color: color, width: 2)),
              child: Text(entry.verdictName,
                  style: News.mono(10,
                      color: color, weight: FontWeight.w700, spacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRule extends StatelessWidget {
  const _DashedRule();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: CustomPaint(
          size: const Size(double.infinity, 2),
          painter: _DashPainter(),
        ),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NewsInk.black
      ..strokeWidth = 2;
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, 1), Offset(x + 6, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
