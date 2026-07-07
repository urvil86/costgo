/// THE LIST editor — build it at home, before the geofence fires.
/// Bottom sheet: add item + est. price, swipe to remove.
library;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../core/utils/fuzzy_match.dart';
import '../data/db/database.dart';
import '../game/game_controller.dart';
import 'widgets.dart';

Future<void> showListEditor(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: NewsInk.paper,
    shape: const RoundedRectangleBorder(),
    builder: (_) => const _ListEditorSheet(),
  );
}

class _ListEditorSheet extends ConsumerStatefulWidget {
  const _ListEditorSheet();

  @override
  ConsumerState<_ListEditorSheet> createState() => _ListEditorSheetState();
}

class _ListEditorSheetState extends ConsumerState<_ListEditorSheet> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final price = double.tryParse(_price.text.trim()) ?? 0;
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(listItemsProvider).valueOrNull ?? [];
    final total = items.fold(0.0, (s, i) => s + i.estPrice);

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

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text('THE LIST', style: News.anton(22))),
                  Text('EST. \$${money(total)}',
                      style: News.kicker(11)),
                ],
              ),
              const SizedBox(height: 4),
              Text('WRITTEN AT HOME. HONORED IN THE ARENA.',
                  style: News.mono(9, color: NewsInk.grayFaint, spacing: 1)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      style: News.mono(13),
                      textInputAction: TextInputAction.next,
                      decoration: deco('paper towels'),
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
                      decoration: deco('\$'),
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
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Nothing yet. Add what you actually need.\n'
                          'Everything else is a temptation with a barcode.',
                          textAlign: TextAlign.center,
                          style: News.mono(11,
                              color: NewsInk.gray, height: 1.6),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: NewsInk.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: Text('CUT',
                                  style: News.kicker(11,
                                      color: NewsInk.paper)),
                            ),
                            onDismissed: (_) async {
                              final db = ref.read(databaseProvider);
                              await (db.delete(db.listItems)
                                    ..where((r) => r.id.equals(item.id)))
                                  .go();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: NewsInk.rule, width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(item.rawText,
                                          style: News.mono(13))),
                                  Text('\$${money(item.estPrice)}',
                                      style: News.mono(13,
                                          weight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              InkButton(
                onTap: () => Navigator.of(context).pop(),
                color: NewsInk.black,
                pressedColor: NewsInk.blackHover,
                child: Text('DONE',
                    style: News.anton(15, color: NewsInk.paper, spacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
