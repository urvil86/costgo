/// Three-stage matcher: alias expansion → fuzzy scoring → confirmation flags.
///
/// Statuses per spec: matched (on list), impulse (not on list), substituted
/// (close cousin, half penalty). Refund lines become `returned` and are
/// excluded from impulse scoring. Ambiguous matches set `needsConfirmation`
/// so the UI can ask "Is `KS ORG PNT BTR` your `peanut butter`?" and write
/// confirmations back into the alias dictionary.
library;

import '../../core/utils/fuzzy_match.dart';
import 'alias_dictionary.dart';
import 'receipt_models.dart';

class MatcherThresholds {
  const MatcherThresholds({
    this.match = 0.82,
    this.substitute = 0.60,
    this.confirmBelow = 0.90,
  });

  /// At or above: matched.
  final double match;

  /// In [substitute, match): substituted — a close cousin, half penalty.
  final double substitute;

  /// Fuzzy matches below this confidence get a one-tap confirmation.
  final double confirmBelow;
}

class Matcher {
  Matcher(this.aliases, {this.thresholds = const MatcherThresholds()});

  final AliasDictionary aliases;
  final MatcherThresholds thresholds;

  List<MatchResult> match(
      List<ParsedReceiptItem> receiptItems, List<ListEntry> list) {
    final results = <MatchResult>[];
    // Track how many receipt units each list entry has absorbed, so a 3-pack
    // of a planned item counts as matched but overage gets flagged.
    final unitsUsed = <String, int>{for (final e in list) e.id: 0};

    for (final item in receiptItems) {
      if (item.isRefund) {
        results.add(MatchResult(
            receiptItem: item, status: MatchStatus.returned));
        continue;
      }

      final expanded = aliases.expand(item.name);

      ListEntry? best;
      var bestScore = 0.0;
      for (final entry in list) {
        // Score against both the alias-expanded and raw receipt name;
        // take the better. Expansion usually helps, never hurts.
        final s1 = nameSimilarity(expanded, entry.name);
        final s2 = nameSimilarity(item.name, entry.name);
        final s = s1 > s2 ? s1 : s2;
        if (s > bestScore) {
          bestScore = s;
          best = entry;
        }
      }

      if (best != null && bestScore >= thresholds.match) {
        final used = unitsUsed[best.id]!;
        final overage = (used + item.quantity) - best.quantity;
        unitsUsed[best.id] = used + item.quantity;
        results.add(MatchResult(
          receiptItem: item,
          status: MatchStatus.matched,
          listEntry: best,
          confidence: bestScore,
          needsConfirmation: bestScore < thresholds.confirmBelow,
          quantityOverage: overage > 0 ? overage : 0,
        ));
      } else if (best != null && bestScore >= thresholds.substitute) {
        results.add(MatchResult(
          receiptItem: item,
          status: MatchStatus.substituted,
          listEntry: best,
          confidence: bestScore,
          needsConfirmation: true,
        ));
      } else {
        results.add(MatchResult(
          receiptItem: item,
          status: MatchStatus.impulse,
          confidence: bestScore,
        ));
      }
    }
    return results;
  }

  /// Applies a user confirmation from the reveal screen. Writes the alias
  /// back so next month `KS ORG PNT BTR` matches without asking.
  void confirm(MatchResult result, {required bool accepted}) {
    result.needsConfirmation = false;
    if (accepted && result.listEntry != null) {
      aliases.learn(result.receiptItem.name, result.listEntry!.name);
      if (result.status == MatchStatus.substituted) {
        result.status = MatchStatus.matched;
      }
    } else if (!accepted) {
      result.status = MatchStatus.impulse;
      result.listEntry = null;
    }
  }
}
