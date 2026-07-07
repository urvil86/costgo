/// Sport skins — each sport reskins the entire scoring vocabulary.
/// Verdict ladders, headlines, stat labels, mulligan naming: all data here,
/// mirroring the design prototype exactly. Ledger entries FREEZE the wording
/// they were scored under; changing sport later never rewrites history.
library;

class SportSkin {
  const SportSkin({
    required this.key,
    required this.label,
    required this.emoji,
    required this.tripWord,
    required this.parWord,
    required this.ratingLabel,
    required this.startLabel,
    required this.mulliganLabel,
    required this.ruleLine,
    required this.chartLabel,
    required this.verdicts,
    required this.headlines,
  });

  final String key;
  final String label;
  final String emoji;

  /// HOLE / DRIVE / INNING / GAME / MATCH
  final String tripWord;

  /// PAR / THE LINE / THE SPREAD / THE CAP / THE TARGET
  final String parWord;

  /// HANDICAP / QB RATING / BATTING AVG / PER / FORM
  final String ratingLabel;
  final String startLabel;
  final String mulliganLabel;
  final String ruleLine;
  final String chartLabel;

  /// Seven tiers, best → worst.
  final List<String> verdicts;
  final List<String> headlines;

  static const golf = SportSkin(
    key: 'golf',
    label: 'GOLF',
    emoji: '⛳',
    tripWord: 'HOLE',
    parWord: 'PAR',
    ratingLabel: 'HANDICAP',
    startLabel: '⛳ TEE OFF',
    mulliganLabel: 'TAKE A MULLIGAN',
    ruleLine: 'EVERY \$10 OVER PAR = +1 STROKE. NO GIMMES.',
    chartLabel: 'STROKES OVER PAR — LAST TRIPS',
    verdicts: [
      'EAGLE', 'BIRDIE', 'PAR', 'BOGEY', 'DOUBLE BOGEY', 'TRIPLE BOGEY',
      'SNOWMAN',
    ],
    headlines: [
      'Local legend eagles the warehouse; economists baffled',
      'Discipline sighted in aisle 12; witnesses stunned',
      'Shopper shoots par; Frank has nothing to say',
      "Bogey at the warehouse; 'it was on sale,' claims suspect",
      "Double bogey disaster; cart 'had a mind of its own'",
      "Local hero shoots triple bogey; blames 'deals'",
      'Snowman in July: budget found dead in parking lot',
    ],
  );

  static const football = SportSkin(
    key: 'football',
    label: 'FOOTBALL',
    emoji: '🏈',
    tripWord: 'DRIVE',
    parWord: 'THE LINE',
    ratingLabel: 'QB RATING',
    startLabel: '🏈 KICKOFF',
    mulliganLabel: 'CHALLENGE FLAG',
    ruleLine: 'EVERY \$10 OVER THE LINE = A SACK. PROTECT THE WALLET.',
    chartLabel: 'SACKS TAKEN — LAST DRIVES',
    verdicts: [
      'TOUCHDOWN', 'FIELD GOAL', 'FIRST DOWN', 'SACK', 'FUMBLE',
      'INTERCEPTION', 'PICK SIX',
    ],
    headlines: [
      'Touchdown! Shopper marches the length of the store untouched',
      'Field goal: three points of pure restraint split the uprights',
      'Chains move; budget survives the review',
      "Sacked in the snack aisle; offensive line 'never showed up'",
      'Fumble! Wallet stripped at the goal line, deals recover',
      'Intercepted! Cart audible goes horribly wrong',
      'Pick six: budget returned for a touchdown the other way',
    ],
  );

  static const baseball = SportSkin(
    key: 'baseball',
    label: 'BASEBALL',
    emoji: '⚾',
    tripWord: 'INNING',
    parWord: 'THE SPREAD',
    ratingLabel: 'BATTING AVG',
    startLabel: '⚾ PLAY BALL',
    mulliganLabel: 'APPEAL THE CALL',
    ruleLine: "EVERY \$10 OVER = A STRIKE. THREE AND YOU'RE OUT.",
    chartLabel: 'STRIKEOUTS — LAST INNINGS',
    verdicts: [
      'GRAND SLAM', 'BASE HIT', 'WALK', 'FOUL BALL', 'STRIKEOUT',
      'DOUBLE PLAY', 'GOLDEN SOMBRERO',
    ],
    headlines: [
      'Grand slam! Shopper clears the bases and beats the budget',
      'Clean single up the middle; manager nods quietly',
      'A walk. Boring. Effective. Frank respects it.',
      'Foul ball: budget stays alive on a technicality',
      'Caught looking: strikeout at the register',
      'Double play! Two impulse buys, one motion, inning over',
      'Golden sombrero: four whiffs and a very full cart',
    ],
  );

  static const basketball = SportSkin(
    key: 'basketball',
    label: 'HOOPS',
    emoji: '🏀',
    tripWord: 'GAME',
    parWord: 'THE CAP',
    ratingLabel: 'PER',
    startLabel: '🏀 TIP-OFF',
    mulliganLabel: 'DEMAND REPLAY',
    ruleLine: 'EVERY \$10 OVER THE CAP = A TURNOVER. TAKE CARE OF THE BALL.',
    chartLabel: 'TURNOVERS — LAST GAMES',
    verdicts: [
      'BUZZER BEATER', 'SWISH', 'FREE THROW', 'RIMMED OUT', 'AIRBALL',
      'SHOT CLOCK VIOLATION', 'FOULED OUT',
    ],
    headlines: [
      'Buzzer beater! Budget wins it from half court',
      'Nothing but net: a clean, disciplined possession',
      'Free throws: unglamorous, effective, on budget',
      'Rimmed out: so close, and yet over the cap',
      "Airball! Crowd chants 'put the cart down'",
      'Shot clock violation: 45 minutes in the store, nothing off the list',
      'Fouled out: five personal fouls, all of them snacks',
    ],
  );

  static const soccer = SportSkin(
    key: 'soccer',
    label: 'SOCCER',
    emoji: '⚽',
    tripWord: 'MATCH',
    parWord: 'THE TARGET',
    ratingLabel: 'FORM',
    startLabel: '⚽ KICKOFF',
    mulliganLabel: 'GO TO VAR',
    ruleLine: 'EVERY \$10 OVER = A BOOKING. VAR IS ALWAYS WATCHING.',
    chartLabel: 'CARDS SHOWN — LAST MATCHES',
    verdicts: [
      'GOLAZO', 'GOAL', 'NIL-NIL DRAW', 'OFFSIDE', 'YELLOW CARD',
      'RED CARD', 'OWN GOAL',
    ],
    headlines: [
      'GOLAZO! Top corner, no VAR needed, budget untouchable',
      'Goal! A tidy finish from a disciplined build-up',
      'Nil-nil draw: nobody scored, nobody got hurt',
      'Flag is up: offside at the checkout',
      "Yellow card for simulation: claimed the bulk buy would 'save money'",
      'RED CARD! Sent off in aisle 9 for reckless cart conduct',
      'Own goal: shopper beats their own budget from 40 yards',
    ],
  );

  static const all = [golf, football, baseball, basketball, soccer];

  static SportSkin byKey(String key) =>
      all.firstWhere((s) => s.key == key, orElse: () => golf);
}
