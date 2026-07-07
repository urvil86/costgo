/// Costco receipt parser.
///
/// ⚠️ CORPUS FLAG (from the build spec): these rules were written against the
/// commonly documented Costco receipt shape — `[item code] [ABBREV NAME]
/// [price]`, discount lines referencing item codes, then SUBTOTAL/TAX/TOTAL.
/// They MUST be validated and tuned against 10–15 real receipt photos before
/// ship. Everything tunable lives in [ReceiptParserRules] so tuning is a
/// data change, not a rewrite.
library;

import 'receipt_models.dart';

/// All heuristics in one place, data-driven per spec.
class ReceiptParserRules {
  const ReceiptParserRules({
    this.itemCodePattern = r'\d{4,7}',
    this.gasKeywords = const ['GALLON', 'PUMP#', 'PUMP #', 'REGULAR UNLEADED',
        'PREMIUM UNLEADED', 'PRICE/GAL', 'FUEL'],
    this.foodCourtKeywords = const ['FOOD COURT', 'HOT DOG', 'CHICKEN BAKE',
        'BERRY SUNDAE', 'SLICE COMBO'],
    this.discountMarkers = const ['TPD', 'INSTANT SAVINGS', '/'],
    this.metaMarkers = const ['MEMBER', 'WHOLESALE', 'SELF-CHECKOUT',
        'CASHIER', 'THANK YOU', 'ITEMS SOLD', 'APPROVED', 'CHIP READ',
        'XXXXXXXX', 'AID:', 'SEQ', 'APP#', 'RESP:', 'TRAN', 'CHANGE',
        'CASH', 'DEBIT', 'VISA', 'MASTERCARD', 'EBT', 'WHSE', 'OP#'],
  });

  final String itemCodePattern;
  final List<String> gasKeywords;
  final List<String> foodCourtKeywords;
  final List<String> discountMarkers;
  final List<String> metaMarkers;
}

class ReceiptParser {
  ReceiptParser({this.rules = const ReceiptParserRules()});

  final ReceiptParserRules rules;

  /// Price token at end of line: `12.99`, `4.99-` (trailing minus = negative,
  /// Costco prints refunds/discounts this way), `-4.99`, optional trailing
  /// tax-flag letter (A/E/Y etc). OCR sometimes reads `12,99` — accept comma.
  static final RegExp _priceAtEnd = RegExp(
      r'(-?)\$?(\d{1,4})[.,](\d{2})\s*(-?)\s*([A-Z]{0,2})$');

  ParsedReceipt parse(String ocrText) {
    final lines = ocrText
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final upper = ocrText.toUpperCase();
    final kind = _classify(upper);

    final parsed = <ParsedLine>[];
    for (final line in lines) {
      parsed.add(_parseLine(line));
    }

    final items = <ParsedReceiptItem>[];
    final byCode = <String, ParsedReceiptItem>{};
    double? subtotal, tax, total;
    final warnings = <String>[];

    for (final line in parsed) {
      switch (line.kind) {
        case LineKind.item:
          final existing = byCode[line.itemCode];
          // Identical repeated line = quantity > 1 (Costco prints one line
          // per unit for most items).
          if (existing != null &&
              existing.name == line.name &&
              (existing.price - (line.price ?? 0)).abs() < 0.005) {
            existing.quantity += 1;
          } else {
            final item = ParsedReceiptItem(
              rawLine: line.rawLine,
              itemCode: line.itemCode ?? '',
              name: line.name ?? '',
              price: line.price ?? 0,
            );
            items.add(item);
            if (line.itemCode != null) byCode[line.itemCode!] = item;
          }
        case LineKind.refund:
          items.add(ParsedReceiptItem(
            rawLine: line.rawLine,
            itemCode: line.itemCode ?? '',
            name: line.name ?? '',
            price: line.price ?? 0,
            isRefund: true,
          ));
        case LineKind.discount:
          final target = line.referencedItemCode != null
              ? byCode[line.referencedItemCode]
              : (items.isNotEmpty && !items.last.isRefund ? items.last : null);
          if (target != null) {
            target.discount += -(line.price ?? 0); // stored positive
          } else {
            warnings.add('Unattached discount: "${line.rawLine}"');
          }
        case LineKind.subtotal:
          subtotal = line.price;
        case LineKind.tax:
          tax = line.price;
        case LineKind.total:
          total = line.price;
        case LineKind.meta:
          break;
      }
    }

    final receipt = ParsedReceipt(
      kind: kind,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      warnings: warnings,
    );

    if (!receipt.reconciles) {
      warnings.add(
          'Items sum to \$${receipt.computedItemTotal.toStringAsFixed(2)} but '
          'subtotal reads \$${subtotal!.toStringAsFixed(2)} — possible OCR '
          'miss. Ask for a retake of the unclear segment.');
    }
    if (items.isEmpty && kind == ReceiptKind.warehouse) {
      warnings.add('No item lines recognized — receipt may be blurry.');
    }
    return receipt;
  }

  ReceiptKind _classify(String upperText) {
    if (rules.gasKeywords.any(upperText.contains)) return ReceiptKind.gas;
    if (rules.foodCourtKeywords.any(upperText.contains)) {
      return ReceiptKind.foodCourt;
    }
    if (upperText.contains('SUBTOTAL') || upperText.contains('TOTAL')) {
      return ReceiptKind.warehouse;
    }
    return ReceiptKind.unknown;
  }

  ParsedLine _parseLine(String line) {
    final upper = line.toUpperCase();

    // Totals block — check before item parsing so "SUBTOTAL 123.45" doesn't
    // read as an item.
    if (RegExp(r'^\W*SUBTOTAL\b').hasMatch(upper)) {
      return ParsedLine(
          kind: LineKind.subtotal, rawLine: line, price: _extractPrice(line));
    }
    if (RegExp(r'^\W*TAX\b').hasMatch(upper)) {
      return ParsedLine(
          kind: LineKind.tax, rawLine: line, price: _extractPrice(line));
    }
    if (RegExp(r'^\W*\**\s*TOTAL\b').hasMatch(upper)) {
      return ParsedLine(
          kind: LineKind.total, rawLine: line, price: _extractPrice(line));
    }
    if (rules.metaMarkers.any((m) => _containsMarker(upper, m))) {
      return ParsedLine(kind: LineKind.meta, rawLine: line);
    }

    final priceMatch = _priceAtEnd.firstMatch(line);
    if (priceMatch == null) {
      return ParsedLine(kind: LineKind.meta, rawLine: line);
    }
    final negative =
        priceMatch.group(1) == '-' || priceMatch.group(4) == '-';
    var price = double.parse(
        '${priceMatch.group(2)}.${priceMatch.group(3)}');
    if (negative) price = -price;

    var body = line.substring(0, priceMatch.start).trim();
    // Leading tax-flag letter(s) before the item code, e.g. "E 96716 ...".
    body = body.replaceFirst(RegExp(r'^[A-Z]\s+(?=\d)'), '');

    final codeMatch =
        RegExp('^(${rules.itemCodePattern})\\s+').firstMatch(body);
    final itemCode = codeMatch?.group(1);
    final name =
        (codeMatch != null ? body.substring(codeMatch.end) : body).trim();

    if (negative) {
      // Discount lines reference a parent code either in the name
      // ("TPD/1648955") or are TPD/instant-savings markers.
      final refMatch = RegExp('/\\s*(${rules.itemCodePattern})')
          .firstMatch(name);
      final isDiscount = refMatch != null ||
          rules.discountMarkers
              .any((m) => m != '/' && name.toUpperCase().contains(m));
      if (isDiscount) {
        return ParsedLine(
          kind: LineKind.discount,
          rawLine: line,
          itemCode: itemCode,
          name: name,
          price: price,
          referencedItemCode: refMatch?.group(1) ?? itemCode,
        );
      }
      // Negative, not a discount → a return/refund line.
      return ParsedLine(
        kind: LineKind.refund,
        rawLine: line,
        itemCode: itemCode,
        name: name,
        price: price,
      );
    }

    if (itemCode == null && name.length < 3) {
      return ParsedLine(kind: LineKind.meta, rawLine: line);
    }
    return ParsedLine(
      kind: LineKind.item,
      rawLine: line,
      itemCode: itemCode,
      name: name,
      price: price,
    );
  }

  /// Marker match with word boundaries so 'CASH' doesn't flag CASHEWS.
  static bool _containsMarker(String upperLine, String marker) {
    final pattern = RegExp(
        '(?<![A-Z])${RegExp.escape(marker)}(?![A-Z])');
    return pattern.hasMatch(upperLine);
  }

  double? _extractPrice(String line) {
    final m = _priceAtEnd.firstMatch(line.trim());
    if (m == null) return null;
    var p = double.parse('${m.group(2)}.${m.group(3)}');
    if (m.group(1) == '-' || m.group(4) == '-') p = -p;
    return p;
  }
}

/// Multi-shot stitching: concatenates OCR segments captured top-to-bottom,
/// dropping overlapping lines between consecutive segments.
String stitchSegments(List<String> segments) {
  if (segments.isEmpty) return '';
  final result = segments.first.split('\n').map((l) => l.trim()).toList();
  for (var i = 1; i < segments.length; i++) {
    final next = segments[i].split('\n').map((l) => l.trim()).toList();
    // Find the largest suffix of `result` that is a prefix of `next`.
    var overlap = 0;
    final maxCheck = next.length < result.length ? next.length : result.length;
    for (var k = maxCheck; k > 0; k--) {
      var match = true;
      for (var j = 0; j < k; j++) {
        if (result[result.length - k + j] != next[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        overlap = k;
        break;
      }
    }
    result.addAll(next.skip(overlap));
  }
  return result.join('\n');
}
