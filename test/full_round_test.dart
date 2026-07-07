/// End-to-end tests for the real user flow:
///  · fresh install lands on onboarding, finishing it lands on THE LIST
///  · full round: list → I'M AT COSTCO → budget → live trip → scan →
///    verdict → challenge flag → sign card → ledger updated
///  · back buttons work at every step
library;

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cartgolf/core/utils/fuzzy_match.dart';
import 'package:cartgolf/data/db/database.dart';
import 'package:cartgolf/features/matching/alias_dictionary.dart';
import 'package:cartgolf/features/roasts/frank.dart';
import 'package:cartgolf/game/game_controller.dart';
import 'package:cartgolf/main.dart';

/// Fixed deck so tests never touch rootBundle (asset-channel futures can't
/// complete inside testWidgets' FakeAsync zone).
const _testDeck = [
  Temptation(
      name: 'KRKLND HOODIE XXL',
      fullName: 'Kirkland Hoodie, XXL',
      price: 16.99,
      tease: 'You came for eggs.',
      roast: 'You came for eggs and left dressed as the store.'),
  Temptation(
      name: 'INFLTBL KAYAK 2P',
      fullName: 'Inflatable Kayak, 2-person',
      price: 189.99,
      tease: 'You live 200 miles from water.',
      roast: 'THE KAYAK. The prophecy is fulfilled.'),
  Temptation(
      name: 'GUMMI BEARS 6LB',
      fullName: 'Gummy Bears, 6 lb',
      price: 12.99,
      tease: '41 days of regret.',
      roast: 'Six pounds of gummy bears.'),
  Temptation(
      name: 'RTSSRE CHKN',
      fullName: 'Rotisserie Chicken',
      price: 4.99,
      tease: 'Third one this month.',
      roast: 'The chicken is never the problem.'),
];

Future<void> pumpFrames(WidgetTester tester,
    [int frames = 8,
    Duration step = const Duration(milliseconds: 120)]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

// NOTE: no db.close teardown — closing drift inside testWidgets' FakeAsync
// zone awaits stream-cleanup timers nothing pumps after the body returns.
// The in-memory database dies with the process.
Future<AppDatabase> _seededDb({
  bool onboarded = true,
  String sport = 'football',
  bool withList = true,
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  for (final e in {
    'onboarded': '$onboarded',
    'sportKey': sport,
    'tone': 'savage',
    'playerName': 'Alex',
  }.entries) {
    await db.into(db.keyValueSettings).insert(
        KeyValueSettingsCompanion.insert(key: e.key, value: e.value));
  }
  if (!withList) return db;
  for (final (name, price) in [('eggs', 7.99), ('paper towels', 21.99)]) {
    await db.into(db.listItems).insert(ListItemsCompanion.insert(
          rawText: name,
          normalizedText: normalizeTokens(name).join(' '),
          estPrice: drift.Value(price),
        ));
  }
  return db;
}

Future<void> _pumpApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        temptationsDeckProvider.overrideWith((ref) async => _testDeck),
        aliasDictionaryProvider.overrideWith(
            (ref) async => AliasDictionary(AliasDictionary.defaultSeed)),
      ],
      child: const CostGoApp(),
    ),
  );
  await pumpFrames(tester);
}

Future<void> _drainTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install: onboarding explains the loop, then the list',
      (tester) async {
    final db = await _seededDb(onboarded: false);
    await _pumpApp(tester, db);

    // Page 1 — what the app is.
    expect(find.text('THIS APP IS HOW YOU FIGHT BACK.'), findsOneWidget);
    expect(find.textContaining('Scan the receipt'), findsOneWidget);
    await tester.tap(find.text('NEXT'));
    await pumpFrames(tester, 4);

    // Page 2 — sport + name.
    expect(find.text('PICK YOUR SPORT'), findsOneWidget);
    await tester.tap(find.text('HOOPS'));
    await pumpFrames(tester, 2);
    await tester.tap(find.text('NEXT'));
    await pumpFrames(tester, 4);

    // Page 3 — tone, then done.
    expect(find.textContaining('HOW HARD SHOULD'), findsOneWidget);
    expect(find.textContaining('NO ACCOUNT NEEDED'), findsOneWidget);
    await tester.tap(find.text('BUILD MY FIRST LIST →'));
    await pumpFrames(tester);

    // Lands on THE LIST tab with hoops persisted.
    expect(find.text('THE LIST'), findsWidgets);
    final saved = await (db.select(db.keyValueSettings)).get();
    final map = {for (final r in saved) r.key: r.value};
    expect(map['onboarded'], 'true');
    expect(map['sportKey'], 'basketball');

    await _drainTimers(tester);
  });

  testWidgets('a full football drive from list to ledger', (tester) async {
    final db = await _seededDb();
    await _pumpApp(tester, db);

    // Shell opens on the FRONT PAGE; THE LIST is one tap away.
    expect(find.text('THE DAILY CART'), findsOneWidget);
    await tester.tap(find.text('THE LIST'));
    await pumpFrames(tester, 3);
    expect(find.text('eggs'), findsOneWidget);
    expect(find.text("I'M AT COSTCO — LET'S GO"), findsOneWidget);
    await tester.tap(find.text("I'M AT COSTCO — LET'S GO"));
    await pumpFrames(tester);

    // Step 1: budget. Football vocabulary, personalized greeting.
    expect(find.text('SET YOUR BUDGET'), findsOneWidget);
    expect(find.text('GOOD LUCK IN THERE, ALEX.'), findsOneWidget);
    for (var i = 0; i < 13; i++) {
      await tester.tap(find.text('−'));
      await tester.pump();
    }
    expect(find.text('\$20'), findsOneWidget);
    await tester.tap(find.text('🏈 KICKOFF'));
    await pumpFrames(tester);

    // Step 2: live trip.
    expect(find.textContaining('DRIVE · LIVE'), findsOneWidget);
    await tester.tap(find.text('eggs'));
    await pumpFrames(tester, 2);
    final giveIn = find.text('GIVE IN').first;
    await tester.scrollUntilVisible(giveIn, 120,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(giveIn);
    await pumpFrames(tester, 2);
    expect(find.text('IN CART ✓'), findsOneWidget);

    // Step 3: checkout → scan.
    await tester.tap(find.text('CHECKOUT → SCAN RECEIPT'));
    await pumpFrames(tester);
    expect(find.text('SCAN YOUR RECEIPT'), findsOneWidget);

    // Back button returns to the trip with the cart intact…
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await pumpFrames(tester);
    expect(find.text('IN CART ✓'), findsOneWidget);
    // …and forward again.
    await tester.tap(find.text('CHECKOUT → SCAN RECEIPT'));
    await pumpFrames(tester);

    await tester.tap(find.text('NO RECEIPT — SCORE THE CART AS TRACKED'));
    await pumpFrames(tester);
    expect(find.text('YOUR RECEIPT, DECODED'), findsOneWidget);
    expect(find.text('UNPLANNED'), findsOneWidget);

    // Step 4: judgment.
    await tester.tap(find.text('CONFIRM & FACE JUDGMENT'));
    await pumpFrames(tester);
    expect(find.text('SPECIAL EDITION'), findsOneWidget);
    expect(find.textContaining('"Alex,"'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.textContaining('ALEX, SENIOR WAREHOUSE CORRESPONDENT'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('ALEX, SENIOR WAREHOUSE CORRESPONDENT'),
        findsOneWidget);
    expect(find.text('CHALLENGE FLAG'), findsOneWidget);

    await tester.tap(find.text('CHALLENGE FLAG'));
    await pumpFrames(tester);
    expect(find.text('CHALLENGE FLAG'), findsNothing); // one per drive

    await tester.tap(find.text('SIGN CARD'));
    await pumpFrames(tester);

    // Signing lands on the FRONT PAGE with the fresh headline and ledger row.
    expect(find.text('LAST EDITION'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    final entry = await (db.select(db.ledgerEntries)).getSingle();
    expect(entry.sportKey, 'football');
    expect(entry.tripWord, 'DRIVE');
    expect(entry.mulliganUsed, isTrue);
    // Eggs only ($7.99) vs par $20 → comfortably under → FIELD GOAL tier 1.
    expect(entry.verdictName, 'FIELD GOAL');
    expect(entry.strokes, -1);

    await _drainTimers(tester);
  });

  testWidgets('abandoning a trip scores nothing', (tester) async {
    final db = await _seededDb();
    await _pumpApp(tester, db);

    await tester.tap(find.text('THE LIST'));
    await pumpFrames(tester, 3);
    await tester.tap(find.text("I'M AT COSTCO — LET'S GO"));
    await pumpFrames(tester);
    await tester.tap(find.text('🏈 KICKOFF'));
    await pumpFrames(tester);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await pumpFrames(tester, 3);
    expect(find.text('ABANDON THIS TRIP?'), findsOneWidget);
    await tester.tap(find.text('ABANDON'));
    await pumpFrames(tester);

    expect(find.text("I'M AT COSTCO — LET'S GO"), findsOneWidget);
    expect(await (db.select(db.ledgerEntries)).get(), isEmpty);

    await _drainTimers(tester);
  });

  testWidgets('freestyle: no list, paste receipt, tap to mark planned',
      (tester) async {
    final db = await _seededDb(withList: false);
    await _pumpApp(tester, db);

    // Empty list → the CTA offers a freestyle trip instead of a dead end.
    await tester.tap(find.text('THE LIST'));
    await pumpFrames(tester, 3);
    expect(find.text('NO LIST — FREESTYLE TRIP'), findsOneWidget);
    await tester.tap(find.text('NO LIST — FREESTYLE TRIP'));
    await pumpFrames(tester);
    expect(find.textContaining('FREESTYLE ROUND'), findsOneWidget);

    await tester.tap(find.text('🏈 KICKOFF'));
    await pumpFrames(tester);
    expect(find.textContaining('Freestyle round — no list'), findsOneWidget);

    await tester.tap(find.text('CHECKOUT → SCAN RECEIPT'));
    await pumpFrames(tester);

    // Paste a real receipt through the actual parser.
    await tester.tap(find.text('PASTE RECEIPT TEXT'));
    await pumpFrames(tester, 3);
    await tester.enterText(
      find.descendant(
          of: find.byType(AlertDialog), matching: find.byType(TextField)),
      '96716 KS ORG PNT BTR 9.99\n'
      '1648955 KS PAPER TWL 21.99\n'
      'SUBTOTAL 31.98\n'
      '**** TOTAL 31.98',
    );
    await tester.tap(find.text('PARSE IT'));
    await pumpFrames(tester);

    // Everything arrives unplanned; one tap reclassifies.
    expect(find.text('UNPLANNED'), findsNWidgets(2));
    await tester.tap(find.text('KS ORG PNT BTR'));
    await pumpFrames(tester, 2);
    expect(find.text('PLANNED'), findsOneWidget);
    expect(find.text('UNPLANNED'), findsOneWidget);

    await tester.tap(find.text('CONFIRM & FACE JUDGMENT'));
    await pumpFrames(tester);
    await tester.tap(find.text('SIGN CARD'));
    await pumpFrames(tester);

    final entry = await (db.select(db.ledgerEntries)).getSingle();
    // $31.98 against $150 → 118 under → best tier, football wording.
    expect(entry.verdictName, 'TOUCHDOWN');
    // Only the still-unplanned paper towels count as impulse damage.
    expect(entry.impulseDollars, closeTo(21.99, 0.001));

    await _drainTimers(tester);
  });
}
