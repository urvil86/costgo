/// Cost-Go game state — trip flow state machine + persistence.
///
/// The shell (3 tabs: THE LIST / FRONT PAGE / STATS) lives in main.dart.
/// This controller owns the trip flow that takes over the screen:
/// home → startTrip (set budget) → trip (live) → scan → roast → home.
/// Every step has a way back; nothing is scored until the card is signed.
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/fuzzy_match.dart';
import '../data/db/database.dart';
import '../features/matching/alias_dictionary.dart';
import '../features/pricing/price_book.dart';
import '../features/matching/matcher.dart';
import '../features/matching/receipt_models.dart';
import '../features/matching/receipt_parser.dart';
import '../features/roasts/frank.dart';
import '../features/scoring/verdict_engine.dart';
import '../features/sports/sport_skin.dart';

enum GameScreen { home, startTrip, trip, scan, roast }

enum TemptChoice { added, resisted }

/// One row on the receipt-review screen.
class ParsedRow {
  const ParsedRow({
    required this.raw,
    required this.full,
    required this.price,
    required this.confidence,
    required this.impulse,
  });

  final String raw;
  final String full;
  final double price;
  final int confidence;
  final bool impulse;
}

class GameState {
  const GameState({
    this.screen = GameScreen.home,
    this.sport = SportSkin.golf,
    this.par = 150,
    this.tripStart,
    this.elapsed = Duration.zero,
    this.checked = const {},
    this.temptDeck = const [],
    this.temptChoices = const {},
    this.hotDog = false,
    this.scanned = false,
    this.snapping = false,
    this.parsedRows = const [],
    this.cartItems = const [],
    this.scanWarnings = const [],
    this.score,
    this.mulliganUsed = false,
    this.frankQuote = '',
  });

  final GameScreen screen;

  /// Snapshotted from settings when the trip starts, so changing sport
  /// mid-round never shifts the scoring language under the player.
  final SportSkin sport;
  final int par;
  final DateTime? tripStart;
  final Duration elapsed;
  final Set<int> checked;
  final List<Temptation> temptDeck;
  final Map<int, TemptChoice> temptChoices;
  final bool hotDog;
  final bool scanned;
  final bool snapping;
  final List<ParsedRow> parsedRows;
  final List<CartItem> cartItems;
  final List<String> scanWarnings;
  final TripScore? score;
  final bool mulliganUsed;
  final String frankQuote;

  GameState copyWith({
    GameScreen? screen,
    SportSkin? sport,
    int? par,
    DateTime? tripStart,
    bool clearTripStart = false,
    Duration? elapsed,
    Set<int>? checked,
    List<Temptation>? temptDeck,
    Map<int, TemptChoice>? temptChoices,
    bool? hotDog,
    bool? scanned,
    bool? snapping,
    List<ParsedRow>? parsedRows,
    List<CartItem>? cartItems,
    List<String>? scanWarnings,
    TripScore? score,
    bool clearScore = false,
    bool? mulliganUsed,
    String? frankQuote,
  }) =>
      GameState(
        screen: screen ?? this.screen,
        sport: sport ?? this.sport,
        par: par ?? this.par,
        tripStart: clearTripStart ? null : (tripStart ?? this.tripStart),
        elapsed: elapsed ?? this.elapsed,
        checked: checked ?? this.checked,
        temptDeck: temptDeck ?? this.temptDeck,
        temptChoices: temptChoices ?? this.temptChoices,
        hotDog: hotDog ?? this.hotDog,
        scanned: scanned ?? this.scanned,
        snapping: snapping ?? this.snapping,
        parsedRows: parsedRows ?? this.parsedRows,
        cartItems: cartItems ?? this.cartItems,
        scanWarnings: scanWarnings ?? this.scanWarnings,
        score: clearScore ? null : (score ?? this.score),
        mulliganUsed: mulliganUsed ?? this.mulliganUsed,
        frankQuote: frankQuote ?? this.frankQuote,
      );
}

// ------------------------------------------------------------------ database

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final listItemsProvider = StreamProvider<List<ListItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.listItems)
        ..orderBy([(i) => drift.OrderingTerm.asc(i.sortOrder)]))
      .watch();
});

final ledgerProvider = StreamProvider<List<LedgerEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.ledgerEntries)
        ..orderBy([(e) => drift.OrderingTerm.desc(e.hole)]))
      .watch();
});

final temptationsDeckProvider = FutureProvider<List<Temptation>>((ref) async {
  final json = jsonDecode(await rootBundle.loadString('assets/temptations.json'))
      as Map<String, dynamic>;
  return [
    for (final t in json['temptations'] as List)
      Temptation.fromJson(t as Map<String, dynamic>)
  ];
});

/// Auto-fill prices: bundled guide + prices learned from signed trips.
/// Invalidated after every signed card so fresh receipts teach it.
final priceBookProvider = FutureProvider<PriceBook>((ref) async {
  final json = jsonDecode(await rootBundle.loadString('assets/price_guide.json'))
      as Map<String, dynamic>;
  final guide = (json['prices'] as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, (v as num).toDouble()));
  final db = ref.read(databaseProvider);
  final learned = await db.select(db.learnedPrices).get();
  return PriceBook(
    guide: guide,
    learned: {for (final r in learned) r.normalizedName: r.price},
  );
});

final aliasDictionaryProvider = FutureProvider<AliasDictionary>((ref) async {
  final seedJson = jsonDecode(await rootBundle.loadString('assets/aliases.json'))
      as Map<String, dynamic>;
  final dict =
      AliasDictionary(seedJson.map((k, v) => MapEntry(k, v as String)));
  final db = ref.read(databaseProvider);
  final learned = await db.select(db.learnedAliases).get();
  for (final row in learned) {
    dict.learn(row.receiptToken, row.plainText);
  }
  return dict;
});

// ------------------------------------------------------------------ settings

class Settings {
  const Settings({
    this.loaded = false,
    this.onboarded = false,
    this.playerName = '',
    this.sportKey = 'golf',
    this.tone = RoastTone.savage,
    this.rating = 0.0,
  });

  /// False until the persisted values are read — the shell shows the brand
  /// splash instead of flashing the wrong screen.
  final bool loaded;
  final bool onboarded;

  /// Local profile only. No accounts, no cloud — that's the product's
  /// privacy story, not an omission.
  final String playerName;

  /// The chosen scoring language. Lives in settings, snapshotted per trip.
  final String sportKey;
  final RoastTone tone;
  final double rating;

  SportSkin get sport => SportSkin.byKey(sportKey);

  Settings copyWith({
    bool? loaded,
    bool? onboarded,
    String? playerName,
    String? sportKey,
    RoastTone? tone,
    double? rating,
  }) =>
      Settings(
        loaded: loaded ?? this.loaded,
        onboarded: onboarded ?? this.onboarded,
        playerName: playerName ?? this.playerName,
        sportKey: sportKey ?? this.sportKey,
        tone: tone ?? this.tone,
        rating: rating ?? this.rating,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() {
    _load();
    return const Settings();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final rows = await db.select(db.keyValueSettings).get();
    final map = {for (final r in rows) r.key: r.value};
    state = Settings(
      loaded: true,
      onboarded: map['onboarded'] == 'true',
      playerName: map['playerName'] ?? '',
      sportKey: map['sportKey'] ?? 'golf',
      tone: RoastTone.values.asNameMap()[map['tone']] ?? RoastTone.savage,
      rating: double.tryParse(map['rating'] ?? '') ?? 0.0,
    );
  }

  Future<void> update(Settings next) async {
    state = next.copyWith(loaded: true);
    final db = ref.read(databaseProvider);
    for (final e in {
      'onboarded': '${next.onboarded}',
      'playerName': next.playerName,
      'sportKey': next.sportKey,
      'tone': next.tone.name,
      'rating': '${next.rating}',
    }.entries) {
      await db.into(db.keyValueSettings).insertOnConflictUpdate(
          KeyValueSettingsCompanion.insert(key: e.key, value: e.value));
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

// ---------------------------------------------------------------- controller

class GameController extends Notifier<GameState> {
  Timer? _ticker;

  @override
  GameState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const GameState();
  }

  // ---- navigation

  void goHome() {
    _ticker?.cancel();
    state = state.copyWith(
        screen: GameScreen.home, clearTripStart: true, clearScore: true);
  }

  /// "I'M GOING IN" — set the budget before entering the arena.
  void goStartTrip() {
    final sport = ref.read(settingsProvider).sport;
    state = state.copyWith(screen: GameScreen.startTrip, sport: sport);
  }

  /// Back from the budget screen: nothing started yet, just leave.
  void cancelStartTrip() => state = state.copyWith(screen: GameScreen.home);

  /// Back from the live trip. Caller confirms with the user first —
  /// abandoning discards the round entirely.
  void abandonTrip() => goHome();

  /// Back from scan to the live trip (cart intact).
  void backToTrip() => state = state.copyWith(
      screen: GameScreen.trip, scanned: false, snapping: false);

  /// On the scan-results view: retake instead of confirming.
  void rescan() => state = state.copyWith(scanned: false, snapping: false);

  /// Discard an unsigned verdict. Caller confirms first.
  void discardVerdict() => goHome();

  // ---- start-trip screen

  void parUp() => state = state.copyWith(par: state.par + 10);
  void parDown() =>
      state = state.copyWith(par: state.par > 20 ? state.par - 10 : 20);

  Future<void> teeOff() async {
    final deck = await ref.read(temptationsDeckProvider.future);
    final hole = await nextHole();
    // Deterministic rotation: each trip surfaces a different slice of the
    // deck, seeded by hole number (no RNG so tests stay reproducible).
    final temptCount = deck.length < 4 ? deck.length : 4;
    final tempts = [
      for (var i = 0; i < temptCount; i++)
        deck[(hole * 3 + i) % deck.length]
    ];
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final start = state.tripStart;
      if (start != null && state.screen == GameScreen.trip) {
        state = state.copyWith(elapsed: DateTime.now().difference(start));
      }
    });
    state = state.copyWith(
      screen: GameScreen.trip,
      tripStart: DateTime.now(),
      elapsed: Duration.zero,
      checked: {},
      temptDeck: tempts,
      temptChoices: {},
      hotDog: false,
      scanned: false,
      snapping: false,
      parsedRows: [],
      cartItems: [],
      scanWarnings: [],
      clearScore: true,
      mulliganUsed: false,
      frankQuote: '',
    );
  }

  // ---- live trip

  void toggleItem(int id) {
    final next = Set<int>.from(state.checked);
    next.contains(id) ? next.remove(id) : next.add(id);
    state = state.copyWith(checked: next);
  }

  void chooseTempt(int index, TemptChoice choice) {
    state = state.copyWith(
        temptChoices: {...state.temptChoices, index: choice});
  }

  void toggleHotDog() => state = state.copyWith(hotDog: !state.hotDog);

  /// Cart as rung up so far: checked list items + surrendered temptations.
  List<CartItem> cartFromTripState(List<ListItem> listItems) => [
        for (final it in listItems)
          if (state.checked.contains(it.id))
            CartItem(
              name: it.rawText.toUpperCase(),
              fullName: it.rawText,
              price: it.estPrice,
              impulse: false,
            ),
        for (final e in state.temptChoices.entries)
          if (e.value == TemptChoice.added)
            state.temptDeck[e.key].toCartItem(),
      ];

  double runningTotal(List<ListItem> listItems) =>
      cartFromTripState(listItems).fold(0.0, (s, i) => s + i.price);

  void goCheckout() => state = state.copyWith(
      screen: GameScreen.scan, scanned: false, snapping: false);

  // ---- scan

  /// Manual mode: score the cart exactly as tracked in-store. The zero-OCR
  /// path — always available, never blocked on camera quality.
  void useCartAsReceipt(List<ListItem> listItems) {
    final items = cartFromTripState(listItems);
    final rows = [
      for (final (i, item) in items.indexed)
        ParsedRow(
          raw: item.name,
          full: item.fullName,
          price: item.price,
          confidence:
              item.impulse ? 88 + (i * 3) % 10 : 93 + (i * 5) % 7,
          impulse: item.impulse,
        ),
    ];
    state = state.copyWith(
        scanned: true, snapping: false, parsedRows: rows, cartItems: items);
  }

  /// Real OCR path: parse receipt text, match against the list; unmatched
  /// lines are impulse. Returns an error string for un-scoreable receipts.
  Future<String?> ingestOcrText(
      String ocrText, List<ListItem> listItems) async {
    final receipt = ReceiptParser().parse(ocrText);
    if (receipt.kind == ReceiptKind.gas) {
      return 'Gas receipt. Fuel is not a sport. Drive home.';
    }
    if (receipt.kind == ReceiptKind.foodCourt) {
      return 'Food court receipts are a protected class. The \$1.50 combo '
          'does not count. Never has.';
    }
    if (receipt.items.isEmpty) {
      return 'Couldn\'t read anything. Flatten the receipt, better light, '
          'try again.';
    }

    final aliases = await ref.read(aliasDictionaryProvider.future);
    final entries = [
      for (final it in listItems)
        ListEntry(id: '${it.id}', name: it.normalizedText, estPrice: it.estPrice)
    ];
    final matches = Matcher(aliases).match(receipt.items, entries);

    final items = <CartItem>[];
    final rows = <ParsedRow>[];
    for (final m in matches) {
      if (m.status == MatchStatus.returned) continue;
      final ri = m.receiptItem;
      final impulse = m.status == MatchStatus.impulse;
      final full = m.listEntry?.name ?? aliases.expand(ri.name);
      items.add(CartItem(
        name: ri.name,
        fullName: full,
        price: ri.netPrice,
        impulse: impulse,
      ));
      rows.add(ParsedRow(
        raw: ri.name,
        full: full,
        price: ri.netPrice,
        confidence: (m.confidence * 100).round().clamp(40, 99),
        impulse: impulse,
      ));
    }

    // Keep the raw text — every real scan grows the parser corpus.
    final db = ref.read(databaseProvider);
    await db.into(db.receipts).insert(ReceiptsCompanion.insert(
          ocrRawText: ocrText,
          subtotal: drift.Value(receipt.subtotal),
          total: drift.Value(receipt.total),
          itemCount: drift.Value(receipt.items.length),
        ));

    state = state.copyWith(
      scanned: true,
      snapping: false,
      parsedRows: rows,
      cartItems: items,
      scanWarnings: receipt.warnings,
    );
    return null;
  }

  void setSnapping(bool v) => state = state.copyWith(snapping: v);

  /// Tap a decoded row to reclassify planned ↔ unplanned. This is both the
  /// mis-match fix and the whole mechanic of freestyle rounds (no list:
  /// everything arrives unplanned, you claim what you meant to buy).
  void toggleParsedRow(int index) {
    if (index < 0 || index >= state.parsedRows.length) return;
    final rows = [...state.parsedRows];
    final items = [...state.cartItems];
    final r = rows[index];
    rows[index] = ParsedRow(
      raw: r.raw,
      full: r.full,
      price: r.price,
      confidence: r.confidence,
      impulse: !r.impulse,
    );
    final it = items[index];
    items[index] = CartItem(
      name: it.name,
      fullName: it.fullName,
      price: it.price,
      impulse: !it.impulse,
    );
    state = state.copyWith(parsedRows: rows, cartItems: items);
  }

  // ---- verdict

  Future<void> confirmScan() async {
    final score = const VerdictEngine().score(
      sport: state.sport,
      par: state.par,
      items: state.cartItems,
      mulliganUsed: false,
      hotDog: state.hotDog,
    );
    final hole = await nextHole();
    state = state.copyWith(
      screen: GameScreen.roast,
      score: score,
      mulliganUsed: false,
      frankQuote: _quoteFor(score, hole),
    );
  }

  void useMulligan() {
    final current = state.score;
    if (current == null || state.mulliganUsed) return;
    final rescored = const VerdictEngine().score(
      sport: current.sport,
      par: current.par,
      items: current.items,
      mulliganUsed: true,
      hotDog: current.hotDog,
    );
    state = state.copyWith(
      score: rescored,
      mulliganUsed: true,
      frankQuote: _quoteFor(rescored, 0),
    );
  }

  String _quoteFor(TripScore score, int seed) {
    final tone = ref.read(settingsProvider).tone;
    final live = score.liveImpulses;
    String? bespoke;
    if (live.isNotEmpty) {
      final worst = live.reduce((a, b) => a.price >= b.price ? a : b);
      for (final t in state.temptDeck) {
        if (t.name == worst.name) bespoke = t.roast;
      }
    }
    return Frank(tone: tone).quote(score, seed: seed, bespokeRoast: bespoke);
  }

  Future<int> nextHole() async {
    final entries = ref.read(ledgerProvider).valueOrNull;
    if (entries != null) {
      return entries.isEmpty ? 1 : entries.first.hole + 1;
    }
    final db = ref.read(databaseProvider);
    final top = await (db.select(db.ledgerEntries)
          ..orderBy([(e) => drift.OrderingTerm.desc(e.hole)])
          ..limit(1))
        .getSingleOrNull();
    return (top?.hole ?? 0) + 1;
  }

  /// Sign the card: freeze verdict wording into the ledger, roll the rating,
  /// go home.
  Future<void> signCard() async {
    final score = state.score;
    if (score == null) return;
    final db = ref.read(databaseProvider);
    final hole = await nextHole();
    final v = score.verdict;

    await db.into(db.ledgerEntries).insert(LedgerEntriesCompanion.insert(
          hole: hole,
          total: score.finalTotal,
          par: score.par,
          verdictName: v.name,
          strokes: v.strokes,
          tier: v.tier,
          headline: v.headline,
          quote: state.frankQuote,
          sportKey: score.sport.key,
          tripWord: score.sport.tripWord,
          parWord: score.sport.parWord,
          mulliganUsed: drift.Value(score.mulliganUsed),
          hotDog: drift.Value(score.hotDog),
          impulseDollars: drift.Value(
              score.liveImpulses.fold(0.0, (s, i) => s + i.price)),
        ));

    final settings = ref.read(settingsProvider);
    await ref.read(settingsProvider.notifier).update(settings.copyWith(
        rating: VerdictEngine.nextRating(settings.rating, v.strokes)));

    // Learn real prices from this trip so future lists auto-fill with what
    // your warehouse actually charges.
    for (final item in score.items) {
      final key = normalizeTokens(item.fullName).join(' ');
      if (key.isEmpty || item.price <= 0) continue;
      await db.into(db.learnedPrices).insertOnConflictUpdate(
          LearnedPricesCompanion.insert(
              normalizedName: key, price: item.price));
    }
    ref.invalidate(priceBookProvider);

    _ticker?.cancel();
    // Land on the FRONT PAGE so the fresh headline is the first thing seen.
    ref.read(shellTabProvider.notifier).state = 0;
    state = state.copyWith(
      screen: GameScreen.home,
      clearTripStart: true,
      clearScore: true,
    );
  }
}

final gameProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

/// Which shell tab is showing: 0 FRONT PAGE · 1 THE LIST · 2 STATS.
/// Signing a card jumps to 0 so the new headline greets you; finishing
/// onboarding jumps to 1 to build the first list.
final shellTabProvider = StateProvider<int>((ref) => 0);
