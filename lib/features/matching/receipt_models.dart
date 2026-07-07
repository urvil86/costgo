/// Plain models shared by the parser, matcher, and scorer. Kept free of
/// Drift/Flutter imports so the engines are unit-testable in isolation.
library;

enum ReceiptKind { warehouse, gas, foodCourt, unknown }

enum LineKind { item, discount, refund, subtotal, tax, total, meta }

enum MatchStatus { matched, impulse, substituted, returned }

class ParsedLine {
  ParsedLine({
    required this.kind,
    required this.rawLine,
    this.itemCode,
    this.name,
    this.price,
    this.referencedItemCode,
  });

  final LineKind kind;
  final String rawLine;
  final String? itemCode;
  final String? name;
  final double? price; // negative for discounts/refunds
  /// For discount lines that reference the item they apply to.
  final String? referencedItemCode;
}

class ParsedReceiptItem {
  ParsedReceiptItem({
    required this.rawLine,
    required this.itemCode,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.discount = 0,
    this.isRefund = false,
  });

  final String rawLine;
  final String itemCode;
  final String name;

  /// Unit price as printed, before discounts.
  final double price;
  int quantity;
  double discount; // accumulated instant savings, stored positive
  final bool isRefund;

  /// What the shopper actually paid for this line.
  double get netPrice => price * quantity - discount;
}

class ParsedReceipt {
  ParsedReceipt({
    required this.kind,
    required this.items,
    this.subtotal,
    this.tax,
    this.total,
    this.warnings = const [],
  });

  final ReceiptKind kind;
  final List<ParsedReceiptItem> items;
  final double? subtotal;
  final double? tax;
  final double? total;

  /// Parser anomalies worth surfacing (e.g. totals don't reconcile) — used
  /// to prompt a retake instead of failing silently.
  final List<String> warnings;

  double get computedItemTotal =>
      items.fold(0.0, (sum, i) => sum + i.netPrice);

  /// True when the item lines reconcile with the printed subtotal within
  /// tolerance — the parser's main self-check for OCR quality.
  bool get reconciles =>
      subtotal == null || (computedItemTotal - subtotal!).abs() < 0.05;
}

/// A shopping-list item as the matcher sees it.
class ListEntry {
  ListEntry({
    required this.id,
    required this.name,
    this.estPrice,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final double? estPrice;
  final int quantity;
}

class MatchResult {
  MatchResult({
    required this.receiptItem,
    required this.status,
    this.listEntry,
    this.confidence = 1.0,
    this.needsConfirmation = false,
    this.quantityOverage = 0,
  });

  final ParsedReceiptItem receiptItem;
  MatchStatus status;
  ListEntry? listEntry;

  /// Similarity score that produced this match (1.0 for alias hits).
  final double confidence;

  /// Ambiguous matches go through the one-tap confirmation screen.
  bool needsConfirmation;

  /// Units bought beyond the planned quantity (half-penalty each).
  final int quantityOverage;
}
