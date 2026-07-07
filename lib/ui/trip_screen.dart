/// LIVE TRIP — timer, running total vs par danger bar, the list with
/// check-offs, temptations spotted in your cart, the 19th hole hot dog.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../game/game_controller.dart';
import 'list_editor.dart';
import 'widgets.dart';

class TripScreen extends ConsumerWidget {
  const TripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final listItems = ref.watch(listItemsProvider).valueOrNull ?? [];
    final running = ctrl.runningTotal(listItems);
    final par = game.par;
    final overNow = running - par;

    final dangerColor = overNow > 5
        ? NewsInk.red
        : overNow > -20
            ? NewsInk.mustard
            : NewsInk.green;
    final dangerLabel = overNow > 5
        ? '+\$${money(overNow)} OVER ${game.sport.parWord}. WALK AWAY.'
        : overNow > -20
            ? 'APPROACHING ${game.sport.parWord}. STAY SHARP.'
            : 'SAFELY UNDER. FOR NOW.';
    final dangerPct = (running / (par * 1.4)).clamp(0.0, 1.0);
    final parMarkPct = 1 / 1.4;

    final mm = game.elapsed.inMinutes.toString().padLeft(2, '0');
    final ss = (game.elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final checkedCount = game.checked.length;

    return Column(
      children: [
        // Live header with a way out.
        Container(
          color: NewsInk.black,
          child: SafeArea(
            bottom: false,
            child: FlowHeader(
              dark: true,
              step: 'STEP 2 OF 4 — IN THE STORE',
              title: '${game.sport.tripWord} · LIVE',
              onBack: () async {
                final leave = await confirmDialog(
                  context,
                  title: 'ABANDON THIS TRIP?',
                  body: 'Nothing gets scored. Your list is safe. '
                      'The paper will pretend this never happened.',
                  confirmLabel: 'ABANDON',
                );
                if (leave) ctrl.abandonTrip();
              },
              trailing: Text('⏱ $mm:$ss',
                  style: News.mono(12,
                      color: NewsInk.mustard, weight: FontWeight.w700)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            children: [
              // Danger bar
              PaperCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('RUNNING TOTAL', style: News.mono(12)),
                        Text('\$${money(running)}',
                            style:
                                News.mono(12, weight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(game.sport.parWord, style: News.mono(12)),
                        Text('\$$par.00', style: News.mono(12)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        return SizedBox(
                          height: 16,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 3,
                                left: 0,
                                right: 0,
                                height: 10,
                                child: Container(color: NewsInk.rule),
                              ),
                              Positioned(
                                top: 3,
                                left: 0,
                                height: 10,
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 300),
                                  width: w * dangerPct,
                                  color: dangerColor,
                                ),
                              ),
                              // Par tick mark
                              Positioned(
                                top: 0,
                                left: (w * parMarkPct - 1)
                                    .clamp(0.0, w - 2),
                                width: 2,
                                height: 16,
                                child: Container(color: NewsInk.black),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(dangerLabel,
                        style: News.mono(10,
                            color: dangerColor,
                            weight: FontWeight.w700,
                            spacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 2, color: NewsInk.black),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        'THE LIST ($checkedCount/${listItems.length})',
                        style: News.kicker(10)),
                  ),
                  GestureDetector(
                    onTap: () => showListEditor(context),
                    child:
                        Text('EDIT', style: News.kicker(10, color: NewsInk.red)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (listItems.isEmpty)
                PaperCard(
                  child: Text(
                    'Freestyle round — no list. Shop, scan the receipt at '
                    'checkout, then tap each item to mark it planned or '
                    'unplanned. The unplanned ones make the paper.',
                    style: News.mono(11, color: NewsInk.gray, height: 1.5),
                  ),
                ),
              for (final it in listItems)
                _ListRow(
                  name: it.rawText,
                  price: it.estPrice,
                  checked: game.checked.contains(it.id),
                  onTap: () => ctrl.toggleItem(it.id),
                ),
              // Temptations — the classic Costco impulse traps. These are
              // NOT detected; they're a bit of fun. Tap only the ones that
              // actually landed in your cart. (Scanning your real receipt
              // later catches everything automatically.)
              Container(
                color: NewsInk.red,
                margin: const EdgeInsets.only(top: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Text('⚠ THE USUAL SUSPECTS',
                    style: News.kicker(11, color: NewsInk.paper)),
              ),
              const SizedBox(height: 4),
              Text(
                  'Classic Costco traps. Did any actually get you? Tap it. '
                  'Skip the rest — this is optional.',
                  style:
                      News.mono(10, color: NewsInk.gray, height: 1.4)),
              const SizedBox(height: 10),
              for (final (i, t) in game.temptDeck.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TemptCard(
                    index: i,
                    name: t.name,
                    price: t.price,
                    tease: t.tease,
                    choice: game.temptChoices[i],
                  ),
                ),
              // Hot dog
              const SizedBox(height: 6),
              InkButton(
                onTap: ctrl.toggleHotDog,
                color: game.hotDog ? NewsInk.cardDim : Colors.transparent,
                border: const Border.fromBorderSide(
                    BorderSide(color: NewsInk.black, width: 2)),
                padding: const EdgeInsets.all(10),
                child: Text(
                  game.hotDog
                      ? '🌭 19TH HOLE SECURED · \$1.50 · '
                          "DOESN'T COUNT. NEVER HAS."
                      : "+ \$1.50 HOT DOG — THE 19TH HOLE (DOESN'T COUNT)",
                  textAlign: TextAlign.center,
                  style: News.mono(11,
                      weight: FontWeight.w700, spacing: 1),
                ),
              ),
            ],
          ),
        ),
        // Checkout
        GestureDetector(
          onTap: ctrl.goCheckout,
          child: Container(
            color: NewsInk.black,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text('CHECKOUT → SCAN RECEIPT',
                    style: News.anton(17, color: NewsInk.paper, spacing: 2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.name,
    required this.price,
    required this.checked,
    required this.onTap,
  });

  final String name;
  final double price;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: checked ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: NewsInk.rule, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: checked ? NewsInk.black : Colors.transparent,
                  border: Border.all(color: NewsInk.black, width: 2),
                ),
                alignment: Alignment.center,
                child: checked
                    ? Text('✓',
                        style: News.mono(11,
                            color: NewsInk.paper, weight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: News.mono(13).copyWith(
                      decoration: checked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
                ),
              ),
              Text(money(price),
                  style: News.mono(13, weight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemptCard extends ConsumerWidget {
  const _TemptCard({
    required this.index,
    required this.name,
    required this.price,
    required this.tease,
    required this.choice,
  });

  final int index;
  final String name;
  final double price;
  final String tease;
  final TemptChoice? choice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(gameProvider.notifier);
    final added = choice == TemptChoice.added;
    final resisted = choice == TemptChoice.resisted;

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: News.mono(13, weight: FontWeight.w700)),
              Text('\$${money(price)}',
                  style: News.mono(13, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 2),
          Text(tease, style: News.mono(11, color: NewsInk.red)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkButton(
                  onTap: () => ctrl.chooseTempt(index, TemptChoice.added),
                  color: added ? NewsInk.red : Colors.transparent,
                  border: const Border.fromBorderSide(
                      BorderSide(color: NewsInk.black, width: 2)),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(added ? 'IN CART ✓' : 'GIVE IN',
                      style: News.mono(11,
                          color: added ? NewsInk.paper : NewsInk.black,
                          weight: FontWeight.w700,
                          spacing: 1)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkButton(
                  onTap: () =>
                      ctrl.chooseTempt(index, TemptChoice.resisted),
                  border: Border.fromBorderSide(BorderSide(
                      color: resisted ? NewsInk.green : NewsInk.grayFaint,
                      width: 2)),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(resisted ? 'RESISTED ✓' : 'RESIST',
                      style: News.mono(11,
                          color: resisted ? NewsInk.green : NewsInk.gray,
                          weight: FontWeight.w700,
                          spacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
