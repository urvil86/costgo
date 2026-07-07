/// Budget-verdict engine — replaces the stroke-golf scorer from the first
/// design. Par is the trip budget in dollars; the verdict tier comes from
/// how far over/under the final total landed, per the design prototype:
///
///   over ≤ −20 → tier 0 (EAGLE/TOUCHDOWN/…)     over ≤ 15 → tier 3
///   over < −5  → tier 1                          over ≤ 30 → tier 4
///   over ≤ 5   → tier 2 (par)                    over ≤ 50 → tier 5
///                                                else      → tier 6 (SNOWMAN)
///
/// Strokes per tier: −2 −1 0 +1 +2 +3, tier 6 = ceil(over/12) capped at 9.
/// The mulligan (sport-named) strikes the most expensive impulse item, once.
library;

import 'dart:math';

import '../sports/sport_skin.dart';

class CartItem {
  const CartItem({
    required this.name,
    required this.fullName,
    required this.price,
    required this.impulse,
  });

  /// Receipt-style abbreviated name (KS ORG PNT BTR ×3).
  final String name;

  /// Human name (Kirkland Organic Peanut Butter ×3).
  final String fullName;
  final double price;

  /// True when this was not on the list — a temptation that won.
  final bool impulse;
}

enum VerdictColor { green, ink, red }

class Verdict {
  const Verdict({
    required this.tier,
    required this.name,
    required this.strokes,
    required this.color,
    required this.headline,
  });

  /// 0 (best) … 6 (catastrophe).
  final int tier;
  final String name;
  final int strokes;
  final VerdictColor color;
  final String headline;

  bool get underPar => strokes < 0;
  bool get onPar => strokes == 0;
}

class TripScore {
  const TripScore({
    required this.sport,
    required this.par,
    required this.rawTotal,
    required this.finalTotal,
    required this.verdict,
    required this.items,
    required this.mulliganTarget,
    required this.mulliganUsed,
    required this.hotDog,
  });

  final SportSkin sport;
  final int par;

  /// Total before any mulligan.
  final double rawTotal;

  /// Total after mulligan (if used).
  final double finalTotal;
  final Verdict verdict;
  final List<CartItem> items;

  /// Priciest impulse item — what the mulligan strikes. Null = no impulses.
  final CartItem? mulliganTarget;
  final bool mulliganUsed;

  /// The 19th hole. Never counts. Never has.
  final bool hotDog;

  double get over => finalTotal - par;

  List<CartItem> get impulses => items.where((i) => i.impulse).toList();

  /// Impulse items still standing after the mulligan.
  List<CartItem> get liveImpulses => items
      .where((i) =>
          i.impulse && !(mulliganUsed && identical(i, mulliganTarget)))
      .toList();
}

class VerdictEngine {
  const VerdictEngine();

  static CartItem? mulliganTargetOf(List<CartItem> items) {
    CartItem? worst;
    for (final i in items) {
      if (!i.impulse) continue;
      if (worst == null || i.price > worst.price) worst = i;
    }
    return worst;
  }

  TripScore score({
    required SportSkin sport,
    required int par,
    required List<CartItem> items,
    bool mulliganUsed = false,
    bool hotDog = false,
  }) {
    final rawTotal = items.fold(0.0, (s, i) => s + i.price);
    final target = mulliganTargetOf(items);
    final finalTotal =
        mulliganUsed && target != null ? rawTotal - target.price : rawTotal;
    final over = finalTotal - par;

    final int tier;
    if (over <= -20) {
      tier = 0;
    } else if (over < -5) {
      tier = 1;
    } else if (over <= 5) {
      tier = 2;
    } else if (over <= 15) {
      tier = 3;
    } else if (over <= 30) {
      tier = 4;
    } else if (over <= 50) {
      tier = 5;
    } else {
      tier = 6;
    }
    final strokes =
        [-2, -1, 0, 1, 2, 3, min(9, (over / 12).ceil())][tier];
    final color = tier <= 1
        ? VerdictColor.green
        : tier == 2
            ? VerdictColor.ink
            : VerdictColor.red;

    return TripScore(
      sport: sport,
      par: par,
      rawTotal: rawTotal,
      finalTotal: finalTotal,
      verdict: Verdict(
        tier: tier,
        name: sport.verdicts[tier],
        strokes: strokes,
        color: color,
        headline: sport.headlines[tier],
      ),
      items: items,
      mulliganTarget: target,
      mulliganUsed: mulliganUsed && target != null,
      hotDog: hotDog,
    );
  }

  /// Rolling rating: EMA that only punishes over-par rounds, from the
  /// prototype: max(0, round(((h*9 + max(0,strokes)*2)/10)*10)/10).
  static double nextRating(double current, int strokes) =>
      max(0, ((current * 9 + max(0, strokes) * 2) / 10 * 10).round() / 10);
}
