import 'package:flutter_test/flutter_test.dart' hide Matcher;
import 'package:cartgolf/core/utils/fuzzy_match.dart';
import 'package:cartgolf/features/matching/alias_dictionary.dart';
import 'package:cartgolf/features/matching/matcher.dart';
import 'package:cartgolf/features/matching/receipt_models.dart';

ParsedReceiptItem item(String name, double price, {String code = '000000'}) =>
    ParsedReceiptItem(rawLine: '$code $name $price', itemCode: code, name: name, price: price);

void main() {
  final aliases = AliasDictionary(AliasDictionary.defaultSeed);
  final matcher = Matcher(aliases);

  group('alias expansion', () {
    test('expands KS ORG PNT BTR', () {
      expect(aliases.expand('KS ORG PNT BTR'),
          'kirkland organic peanut butter');
    });

    test('unknown tokens pass through lowercased', () {
      expect(aliases.expand('XYZZY WIDGET'), 'xyzzy widget');
    });
  });

  group('fuzzy primitives', () {
    test('jaro-winkler favors shared prefixes', () {
      expect(jaroWinkler('chicken', 'chickn'),
          greaterThan(jaroWinkler('chicken', 'kitchen')));
    });

    test('devowel matches Costco-style abbreviation', () {
      expect(devowel('peanut'), 'pnt');
      expect(devowel('butter'), 'bttr');
    });
  });

  group('three-stage matching', () {
    final list = [
      ListEntry(id: '1', name: 'peanut butter', estPrice: 10),
      ListEntry(id: '2', name: 'paper towels', estPrice: 20),
      ListEntry(id: '3', name: 'rotisserie chicken', estPrice: 5),
      ListEntry(id: '4', name: 'bananas', estPrice: 2),
    ];

    test('abbreviated receipt names match via alias + fuzzy', () {
      final results = matcher.match([
        item('KS ORG PNT BTR', 9.99),
        item('KS PAPER TWL', 21.99),
        item('ROT CHKN', 4.99),
      ], list);
      expect(results.map((r) => r.status),
          everyElement(MatchStatus.matched));
      expect(results[0].listEntry!.id, '1');
      expect(results[1].listEntry!.id, '2');
      expect(results[2].listEntry!.id, '3');
    });

    test('unlisted item is impulse', () {
      final results = matcher.match([item('55IN TCL TV', 229.99)], list);
      expect(results.single.status, MatchStatus.impulse);
    });

    test('refund lines are returned, never impulse', () {
      final refund = ParsedReceiptItem(
          rawLine: 'x', itemCode: '1', name: 'AIR FRYER',
          price: -89.99, isRefund: true);
      final results = matcher.match([refund], list);
      expect(results.single.status, MatchStatus.returned);
    });

    test('quantity above list quantity flags overage', () {
      final bananas = item('BNNS 3LB', 1.99)..quantity = 3;
      final results = matcher.match([bananas], list);
      expect(results.single.status, MatchStatus.matched);
      expect(results.single.quantityOverage, 2);
    });

    test('user confirmation writes back to alias dictionary', () {
      final local = AliasDictionary({});
      final m = Matcher(local);
      final results = m.match([item('KS ALMD FLR', 12.99)],
          [ListEntry(id: '9', name: 'almond flour')]);
      final r = results.single;
      // Whatever stage it landed in, confirming teaches the dictionary.
      r.listEntry ??= ListEntry(id: '9', name: 'almond flour');
      m.confirm(r, accepted: true);
      expect(local.toJson()['KS ALMD FLR'], 'almond flour');
      expect(r.status, MatchStatus.matched);
    });

    test('rejecting a confirmation demotes to impulse', () {
      final results = matcher.match([item('GRK YGRT', 8.99)],
          [ListEntry(id: '5', name: 'greek yogurt')]);
      final r = results.single;
      matcher.confirm(r, accepted: false);
      expect(r.status, MatchStatus.impulse);
      expect(r.listEntry, isNull);
    });
  });
}
