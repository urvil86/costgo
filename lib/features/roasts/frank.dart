/// Frank, Senior Warehouse Correspondent. Savage by default.
///
/// Quote selection: verdict outcome first (under/on par), then the worst
/// surviving impulse item (its bespoke roast if it came from the temptations
/// deck, else a savage template), else the prices-got-you line. Deterministic
/// given the same trip + seed; variety comes from the round number.
library;

import '../scoring/verdict_engine.dart';

enum RoastTone { savage, deadpan, gentle }

class Frank {
  const Frank({this.tone = RoastTone.savage});

  final RoastTone tone;

  static const _underParSavage = [
    "Under par. I don't know who you are anymore, but I like it.",
    'Under budget at a warehouse store. The shareholders have been notified.',
    "You left money in your wallet ON PURPOSE. Unsettling. Impressive.",
    'The samples ladies waved. You waved back and kept walking. Legend.',
  ];

  static const _underParGentle = [
    'Proud of you. Genuinely. Frame this receipt.',
    'Under budget. You did the thing. The newsroom is quietly emotional.',
  ];

  static const _underParDeadpan = [
    'Under par. Recorded. No further comment.',
    'Budget intact. Statistically anomalous. Noted.',
  ];

  static const _onPar = [
    'Dead on par. Suspiciously professional. Are you okay?',
    'Exactly on budget. The desk checked the math twice. Still true. Weird.',
    'On the number. Machines shop like this. Blink twice if you need help.',
  ];

  static const _noImpulseButOver = [
    'No impulse buys and still over par. The prices got you fair and square. Brutal.',
    'Everything was on the list and you STILL went over. Inflation ate your budget in the parking lot.',
    'Clean list, dirty total. The warehouse simply charged you more for being there.',
  ];

  /// Savage templates for impulse items with no bespoke roast. {item} slot.
  static const _savageTemplates = [
    'The {item} was not on the list. The list was not consulted. The list found out from the receipt like everyone else.',
    '{item}. At a warehouse store. On a weekday. This is who you are now.',
    'You defended that {item} in your head for four aisles. None of it held up in editing.',
    "The {item} 'was a great deal.' So is not buying it. That deal is available every day.",
    'Somewhere between the entrance and the {item}, the plan died. The aisle has been taped off.',
    'The {item} goes in the cart, the cart goes to the register, the register tells your bank. That is the whole crime, start to finish.',
    "{item}. Nobody is angry. It is simply going in the permanent file.",
  ];

  static const _deadpanTemplates = [
    '{item}. Noted. Filed. Remembered.',
    '{item}. Entered into evidence without comment.',
    'One {item}. The ledger does not editorialize. Not today, anyway.',
  ];

  static const _gentleTemplates = [
    'The {item} was a choice. We move on. Together.',
    'The {item} happens to the best of us. Next trip is a fresh scorecard.',
  ];

  String quote(TripScore score, {int seed = 0, String? bespokeRoast}) {
    final v = score.verdict;
    if (v.underPar) {
      return _pick(switch (tone) {
        RoastTone.gentle => _underParGentle,
        RoastTone.deadpan => _underParDeadpan,
        RoastTone.savage => _underParSavage,
      }, seed);
    }
    if (v.onPar) return _pick(_onPar, seed);

    final imp = score.liveImpulses;
    if (imp.isEmpty) return _pick(_noImpulseButOver, seed);

    final worst = imp.reduce((a, b) => a.price >= b.price ? a : b);
    if (bespokeRoast != null && tone == RoastTone.savage) return bespokeRoast;

    final templates = switch (tone) {
      RoastTone.gentle => _gentleTemplates,
      RoastTone.deadpan => _deadpanTemplates,
      RoastTone.savage => _savageTemplates,
    };
    return _pick(templates, seed)
        .replaceAll('{item}', worst.fullName.toLowerCase());
  }

  static String _pick(List<String> pool, int seed) =>
      pool[seed % pool.length];
}

/// A temptation from the deck — a classic warehouse ambush with a tease
/// (shown in-store) and a bespoke roast (fired if you gave in).
class Temptation {
  const Temptation({
    required this.name,
    required this.fullName,
    required this.price,
    required this.tease,
    required this.roast,
  });

  final String name;
  final String fullName;
  final double price;
  final String tease;
  final String roast;

  factory Temptation.fromJson(Map<String, dynamic> json) => Temptation(
        name: json['name'] as String,
        fullName: json['full'] as String,
        price: (json['price'] as num).toDouble(),
        tease: json['tease'] as String,
        roast: json['roast'] as String,
      );

  CartItem toCartItem() =>
      CartItem(name: name, fullName: fullName, price: price, impulse: true);
}
