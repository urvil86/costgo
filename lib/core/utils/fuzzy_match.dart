/// Fuzzy string matching utilities for receipt-name ↔ list-item matching.
///
/// Costco receipt names are heavily abbreviated (`KS ORG PNT BTR`), so exact
/// matching fails. The matcher combines token normalization, Jaro-Winkler
/// similarity, and trigram overlap. No external dependencies — everything
/// here is pure Dart so it stays fast and testable.
library;

/// Words that carry no matching signal on either side.
const Set<String> _stopWords = {
  'a', 'an', 'the', 'of', 'and', 'or', 'with', 'for', 'pack', 'ct', 'count',
  'oz', 'lb', 'lbs', 'kg', 'g', 'ml', 'l', 'each', 'per',
  // Brand noise: on nearly every receipt line, almost never on a list.
  'ks', 'kirkland', 'signature',
};

/// Normalizes a name into comparable tokens: lowercase, strip punctuation
/// and digits, drop stop words, singularize naively.
List<String> normalizeTokens(String input) {
  final cleaned = input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty && !_stopWords.contains(t))
      .map(_singularize)
      .toList();
  return cleaned;
}

String _singularize(String word) {
  if (word.length <= 3) return word;
  if (word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
  if (word.endsWith('ses')) return word.substring(0, word.length - 2);
  if (word.endsWith('s') && !word.endsWith('ss')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}

/// Removes interior vowels: "peanut" → "pnt". Costco abbreviations tend to
/// keep the first letter and drop vowels, so comparing devoweled forms
/// recovers matches like PNT ↔ peanut.
String devowel(String word) {
  if (word.length <= 2) return word;
  final first = word[0];
  final rest = word.substring(1).replaceAll(RegExp(r'[aeiou]'), '');
  return '$first$rest';
}

/// Jaro similarity in [0, 1].
double jaro(String s1, String s2) {
  if (s1 == s2) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  final matchDistance = (s1.length > s2.length ? s1.length : s2.length) ~/ 2 - 1;
  final s1Matches = List<bool>.filled(s1.length, false);
  final s2Matches = List<bool>.filled(s2.length, false);

  var matches = 0;
  for (var i = 0; i < s1.length; i++) {
    final start = i - matchDistance > 0 ? i - matchDistance : 0;
    final end = i + matchDistance + 1 < s2.length ? i + matchDistance + 1 : s2.length;
    for (var j = start; j < end; j++) {
      if (s2Matches[j] || s1[i] != s2[j]) continue;
      s1Matches[i] = true;
      s2Matches[j] = true;
      matches++;
      break;
    }
  }
  if (matches == 0) return 0.0;

  var transpositions = 0;
  var k = 0;
  for (var i = 0; i < s1.length; i++) {
    if (!s1Matches[i]) continue;
    while (!s2Matches[k]) {
      k++;
    }
    if (s1[i] != s2[k]) transpositions++;
    k++;
  }

  final m = matches.toDouble();
  return (m / s1.length + m / s2.length + (m - transpositions / 2) / m) / 3;
}

/// Jaro-Winkler: Jaro boosted for shared prefixes (up to 4 chars).
double jaroWinkler(String s1, String s2, {double prefixScale = 0.1}) {
  final j = jaro(s1, s2);
  var prefix = 0;
  final maxPrefix = s1.length < s2.length ? s1.length : s2.length;
  for (var i = 0; i < maxPrefix && i < 4; i++) {
    if (s1[i] == s2[i]) {
      prefix++;
    } else {
      break;
    }
  }
  return j + prefix * prefixScale * (1 - j);
}

/// Character trigram similarity (Dice coefficient) in [0, 1].
double trigramSimilarity(String a, String b) {
  final ta = _trigrams(a);
  final tb = _trigrams(b);
  if (ta.isEmpty || tb.isEmpty) return a == b ? 1.0 : 0.0;
  final overlap = ta.intersection(tb).length;
  return 2 * overlap / (ta.length + tb.length);
}

Set<String> _trigrams(String s) {
  final padded = '  ${s.toLowerCase()} ';
  final grams = <String>{};
  for (var i = 0; i + 3 <= padded.length; i++) {
    grams.add(padded.substring(i, i + 3));
  }
  return grams;
}

/// Score how well a (possibly abbreviated) receipt name matches a plain
/// English list-item name. Returns [0, 1]. Symmetric enough in practice,
/// but pass receipt text first.
///
/// Strategy: for each receipt token, find the best-matching list token using
/// max(JW on raw, JW on devoweled, trigram). Average the best scores,
/// weighted toward the receipt side (the abbreviated side carries the
/// signal; extra descriptive words on the list side shouldn't tank it).
double nameSimilarity(String receiptName, String listName) {
  final rTokens = normalizeTokens(receiptName);
  final lTokens = normalizeTokens(listName);
  if (rTokens.isEmpty || lTokens.isEmpty) return 0.0;

  double tokenScore(String r, String l) {
    final scores = [
      jaroWinkler(r, l),
      jaroWinkler(devowel(r), devowel(l)),
      trigramSimilarity(r, l),
      // Abbreviation containment: "pnt" fully inside devoweled "peanut".
      if (devowel(l).startsWith(devowel(r)) || devowel(r).startsWith(devowel(l)))
        0.92,
    ];
    return scores.reduce((a, b) => a > b ? a : b);
  }

  var total = 0.0;
  for (final r in rTokens) {
    var best = 0.0;
    for (final l in lTokens) {
      final s = tokenScore(r, l);
      if (s > best) best = s;
    }
    total += best;
  }
  final receiptCoverage = total / rTokens.length;

  var lTotal = 0.0;
  for (final l in lTokens) {
    var best = 0.0;
    for (final r in rTokens) {
      final s = tokenScore(r, l);
      if (s > best) best = s;
    }
    lTotal += best;
  }
  final listCoverage = lTotal / lTokens.length;

  return 0.65 * receiptCoverage + 0.35 * listCoverage;
}
