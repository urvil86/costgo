/// THE LIST tab — the default home. Build the list here, then hit
/// "I'M GOING IN" when you're at the store. The whole product in one screen.
library;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/theme/news_theme.dart';
import '../core/utils/fuzzy_match.dart';
import '../data/db/database.dart';
import '../game/game_controller.dart';
import 'brand.dart';
import 'settings_screen.dart';
import 'widgets.dart';

class ListTab extends ConsumerStatefulWidget {
  const ListTab({super.key});

  @override
  ConsumerState<ListTab> createState() => _ListTabState();
}

class _ListTabState extends ConsumerState<ListTab> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _nameFocus = FocusNode();
  final _speech = SpeechToText();
  bool _listening = false;

  @override
  void dispose() {
    _speech.cancel();
    _name.dispose();
    _price.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _dictate() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: NewsInk.black,
        shape: const RoundedRectangleBorder(),
        content: Text('Dictation unavailable on this device — keyboard it is.',
            style: News.mono(12, color: NewsInk.paper)),
      ));
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(
          partialResults: true, listenFor: const Duration(seconds: 8)),
      onResult: (result) {
        _name.text = result.recognizedWords;
        if (result.finalResult && mounted) {
          setState(() => _listening = false);
        }
      },
    );
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    // Typed price wins; otherwise the price book fills it in — learned
    // prices from your own receipts first, bundled guide second.
    var price = double.tryParse(_price.text.trim()) ?? 0;
    if (price == 0) {
      final book = await ref.read(priceBookProvider.future);
      price = book.estimate(name)?.price ?? 0;
    }
    final db = ref.read(databaseProvider);
    await db.into(db.listItems).insert(ListItemsCompanion.insert(
          rawText: name,
          normalizedText: normalizeTokens(name).join(' '),
          estPrice: drift.Value(price),
        ));
    _name.clear();
    _price.clear();
    _nameFocus.requestFocus();
  }

  Future<void> _editPrice(ListItem item) async {
    final controller =
        TextEditingController(text: money(item.estPrice));
    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NewsInk.paper,
        shape: const RoundedRectangleBorder(),
        title: Text(item.rawText.toUpperCase(), style: News.anton(16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: News.mono(14),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ '),
          onSubmitted: (v) => Navigator.of(context).pop(double.tryParse(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: News.kicker(11)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(double.tryParse(controller.text)),
            child: Text('SET', style: News.kicker(11, color: NewsInk.red)),
          ),
        ],
      ),
    );
    if (price != null) {
      final db = ref.read(databaseProvider);
      await (db.update(db.listItems)..where((r) => r.id.equals(item.id)))
          .write(ListItemsCompanion(estPrice: drift.Value(price)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(listItemsProvider).valueOrNull ?? [];
    final total = items.fold(0.0, (s, i) => s + i.estPrice);
    final settings = ref.watch(settingsProvider);

    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: News.mono(12, color: NewsInk.grayFaint),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NewsInk.black, width: 2),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: NewsInk.red, width: 2),
          ),
        );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            children: [
              // Brand + settings
              Row(
                children: [
                  const Expanded(child: CostGoLogo(size: 22)),
                  GestureDetector(
                    onTap: () => openSettings(context),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.settings_rounded, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Text('THE LIST', style: News.anton(30))),
                  Text('EST. \$${money(total)}', style: News.kicker(12)),
                ],
              ),
              const SizedBox(height: 2),
              Text('WRITE IT AT HOME. HONOR IT IN THE ARENA.',
                  style: News.mono(9, color: NewsInk.grayFaint, spacing: 1)),
              const SizedBox(height: 14),
              // Add row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      style: News.mono(13),
                      textInputAction: TextInputAction.next,
                      decoration: deco('e.g. paper towels').copyWith(
                        suffixIcon: GestureDetector(
                          onTap: _dictate,
                          child: Icon(
                            _listening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 20,
                            color:
                                _listening ? NewsInk.red : NewsInk.gray,
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _price,
                      style: News.mono(13),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      onSubmitted: (_) => _add(),
                      decoration: deco('\$ auto'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _add,
                    child: Container(
                      width: 44,
                      height: 44,
                      color: NewsInk.black,
                      alignment: Alignment.center,
                      child: Text('+',
                          style: News.mono(20,
                              color: NewsInk.paper,
                              weight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                PaperCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('START HERE', style: News.kicker(10, color: NewsInk.red)),
                      const SizedBox(height: 6),
                      Text(
                          'Add what you actually need — eggs, paper towels, '
                          'the boring stuff. Prices fill in automatically '
                          '(tap any row to adjust).\n\n'
                          'Walking into that store without a list is how '
                          'kayaks happen.',
                          style: News.mono(12, height: 1.5)),
                    ],
                  ),
                ),
              for (final item in items)
                Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: NewsInk.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child:
                        Text('CUT', style: News.kicker(11, color: NewsInk.paper)),
                  ),
                  onDismissed: (_) async {
                    final db = ref.read(databaseProvider);
                    await (db.delete(db.listItems)
                          ..where((r) => r.id.equals(item.id)))
                        .go();
                  },
                  child: GestureDetector(
                    onTap: () => _editPrice(item),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: NewsInk.rule, width: 1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child:
                                  Text(item.rawText, style: News.mono(13))),
                          Text(
                              item.estPrice > 0
                                  ? '\$${money(item.estPrice)}'
                                  : '\$ ?',
                              style: News.mono(13,
                                  weight: FontWeight.w500,
                                  color: item.estPrice > 0
                                      ? NewsInk.black
                                      : NewsInk.red)),
                        ],
                      ),
                    ),
                  ),
                ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'PRICES AUTO-FILLED — TAP TO ADJUST · SWIPE LEFT TO '
                      'REMOVE',
                      style: News.mono(8,
                          color: NewsInk.grayFaint, spacing: 1)),
                ),
            ],
          ),
        ),
        // The CTA — plain language, sport flavor as garnish.
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
          child: SizedBox(
            width: double.infinity,
            child: InkButton(
              onTap: () => ref.read(gameProvider.notifier).goStartTrip(),
              color: NewsInk.red,
              pressedColor: NewsInk.redDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    items.isEmpty
                        ? 'NO LIST — FREESTYLE TRIP'
                        : "I'M AT COSTCO — LET'S GO",
                    style: News.anton(17,
                        color: NewsInk.paper, spacing: 1.5),
                  ),
                  Text(
                      items.isEmpty
                          ? 'SCAN THE RECEIPT, THEN MARK WHAT WAS PLANNED'
                          : '${items.length} ITEMS · SCORED AS '
                              '${settings.sport.label}',
                      style:
                          News.mono(9, color: NewsInk.paper, spacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
