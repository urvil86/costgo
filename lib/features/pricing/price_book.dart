/// Price auto-fill. Learned prices (from your own signed trips) win over the
/// bundled starter guide; both matched fuzzily so "TP" or "kirkland eggs"
/// still resolve. Pure Dart, no Flutter imports.
library;

import '../../core/utils/fuzzy_match.dart';

class PriceEstimate {
  const PriceEstimate(this.price, {required this.learned});

  final double price;

  /// True when it came from the user's own receipts, not the bundled guide.
  final bool learned;
}

class PriceBook {
  PriceBook({required Map<String, double> guide,
      required Map<String, double> learned})
      : _guide = _normalizeKeys(guide),
        _learned = _normalizeKeys(learned);

  final Map<String, double> _guide;
  final Map<String, double> _learned;

  static const _threshold = 0.72;

  static Map<String, double> _normalizeKeys(Map<String, double> src) => {
        for (final e in src.entries)
          normalizeTokens(e.key).join(' '): e.value
      };

  /// Best price guess for a list-item name, or null when nothing is close
  /// enough. Learned prices are checked first — your warehouse's reality
  /// beats the national guess.
  PriceEstimate? estimate(String itemName) {
    final name = normalizeTokens(itemName).join(' ');
    if (name.isEmpty) return null;

    final learnedHit = _bestMatch(name, _learned);
    if (learnedHit != null) {
      return PriceEstimate(learnedHit, learned: true);
    }
    final guideHit = _bestMatch(name, _guide);
    if (guideHit != null) {
      return PriceEstimate(guideHit, learned: false);
    }
    return null;
  }

  double? _bestMatch(String name, Map<String, double> pool) {
    final exact = pool[name];
    if (exact != null) return exact;
    String? bestKey;
    var bestScore = 0.0;
    for (final key in pool.keys) {
      final s = nameSimilarity(name, key);
      if (s > bestScore) {
        bestScore = s;
        bestKey = key;
      }
    }
    return bestScore >= _threshold ? pool[bestKey] : null;
  }
}
