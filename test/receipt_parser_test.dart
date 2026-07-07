// Parser tests run against fixtures in test/fixtures/.
//
// ⚠️ CORPUS FLAG: receipt_typical.txt is a SYNTHETIC fixture built from the
// documented Costco receipt shape. Per the build spec, 10–15 real anonymized
// receipt photos must be collected and added here before the parser is
// trusted. These tests pin current behavior; real fixtures extend them.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:cartgolf/features/matching/receipt_models.dart';
import 'package:cartgolf/features/matching/receipt_parser.dart';

void main() {
  final parser = ReceiptParser();

  group('typical warehouse receipt', () {
    late ParsedReceipt receipt;

    setUpAll(() {
      final text = File('test/fixtures/receipt_typical.txt').readAsStringSync();
      receipt = parser.parse(text);
    });

    test('classified as warehouse', () {
      expect(receipt.kind, ReceiptKind.warehouse);
    });

    test('parses all item lines, merging duplicate lines into quantity', () {
      // 8 distinct items; the duplicated banana line becomes quantity 2.
      expect(receipt.items.length, 8);
      final bananas =
          receipt.items.firstWhere((i) => i.name.contains('BNNS'));
      expect(bananas.quantity, 2);
    });

    test('attaches TPD discount to referenced item code', () {
      final towels =
          receipt.items.firstWhere((i) => i.itemCode == '1648955');
      expect(towels.discount, closeTo(3.00, 0.001));
      expect(towels.netPrice, closeTo(18.99, 0.001));
    });

    test('reads subtotal, tax, total', () {
      expect(receipt.subtotal, closeTo(305.41, 0.001));
      expect(receipt.tax, closeTo(18.92, 0.001));
      expect(receipt.total, closeTo(324.33, 0.001));
    });

    test('items reconcile against printed subtotal', () {
      expect(receipt.reconciles, isTrue);
      expect(receipt.warnings, isEmpty);
    });

    test('never scores tax/subtotal/member lines as items', () {
      expect(
          receipt.items.any((i) =>
              i.name.toUpperCase().contains('TOTAL') ||
              i.name.toUpperCase().contains('TAX') ||
              i.name.toUpperCase().contains('MEMBER')),
          isFalse);
    });

    test('handles leading and trailing tax-flag letters', () {
      final pb = receipt.items.firstWhere((i) => i.itemCode == '96716');
      expect(pb.name, 'KS ORG PNT BTR');
      expect(pb.price, closeTo(9.99, 0.001));
    });
  });

  group('returns and refunds', () {
    test('negative non-discount line becomes a refund item', () {
      final receipt = parser.parse('''
E 96716 KS ORG PNT BTR 9.99
383025 AIR FRYER 89.99-
SUBTOTAL -80.00
**** TOTAL -80.00
''');
      final refund = receipt.items.firstWhere((i) => i.isRefund);
      expect(refund.price, closeTo(-89.99, 0.001));
      expect(refund.name, 'AIR FRYER');
    });
  });

  group('protected receipt classes', () {
    test('detects gas receipts', () {
      final receipt = parser.parse('''
COSTCO GASOLINE
PUMP# 4
REGULAR UNLEADED
12.503 GALLONS @ 4.199
TOTAL 52.50
''');
      expect(receipt.kind, ReceiptKind.gas);
    });

    test('detects food court receipts (Frank forbids scoring these)', () {
      final receipt = parser.parse('''
COSTCO FOOD COURT
HOT DOG 1.50
BERRY SUNDAE 2.49
TOTAL 3.99
''');
      expect(receipt.kind, ReceiptKind.foodCourt);
    });
  });

  group('OCR quality safeguards', () {
    test('flags non-reconciling totals for a retake', () {
      final receipt = parser.parse('''
96716 KS ORG PNT BTR 9.99
SUBTOTAL 47.12
TAX 0.00
**** TOTAL 47.12
''');
      expect(receipt.reconciles, isFalse);
      expect(receipt.warnings, isNotEmpty);
    });

    test('accepts comma-misread decimal points', () {
      final receipt = parser.parse('''
96716 KS ORG PNT BTR 9,99
SUBTOTAL 9.99
**** TOTAL 9.99
''');
      expect(receipt.items.single.price, closeTo(9.99, 0.001));
    });
  });

  group('multi-shot stitching', () {
    test('dedups overlapping lines between segments', () {
      final seg1 = 'LINE A\nLINE B\nLINE C\nLINE D';
      final seg2 = 'LINE C\nLINE D\nLINE E';
      expect(stitchSegments([seg1, seg2]),
          'LINE A\nLINE B\nLINE C\nLINE D\nLINE E');
    });

    test('no overlap concatenates cleanly', () {
      expect(stitchSegments(['A\nB', 'C\nD']), 'A\nB\nC\nD');
    });
  });
}
