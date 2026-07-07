import 'package:flutter_test/flutter_test.dart';
import 'package:cartgolf/features/scoring/verdict_engine.dart';
import 'package:cartgolf/features/sports/sport_skin.dart';

CartItem item(String name, double price, {bool impulse = false}) => CartItem(
    name: name.toUpperCase(), fullName: name, price: price, impulse: impulse);

void main() {
  const engine = VerdictEngine();

  TripScore run(double total, {int par = 150, List<CartItem>? items}) =>
      engine.score(
        sport: SportSkin.golf,
        par: par,
        items: items ?? [item('stuff', total)],
      );

  group('verdict tiers (golf wording)', () {
    test('−\$20 or better under par is an EAGLE', () {
      expect(run(130).verdict.name, 'EAGLE');
      expect(run(130).verdict.strokes, -2);
    });

    test('under by more than \$5 is a BIRDIE', () {
      expect(run(140).verdict.name, 'BIRDIE');
      expect(run(140).verdict.strokes, -1);
    });

    test('within ±\$5 is PAR', () {
      expect(run(149.02).verdict.name, 'PAR');
      expect(run(155).verdict.name, 'PAR');
      expect(run(150).verdict.strokes, 0);
    });

    test('up to +\$15 is a BOGEY', () {
      expect(run(158.40).verdict.name, 'BOGEY');
      expect(run(158.40).verdict.strokes, 1);
    });

    test('up to +\$30 is a DOUBLE BOGEY', () {
      expect(run(174.55).verdict.name, 'DOUBLE BOGEY');
      expect(run(174.55).verdict.strokes, 2);
    });

    test('up to +\$50 is a TRIPLE BOGEY', () {
      expect(run(195).verdict.name, 'TRIPLE BOGEY');
      expect(run(195).verdict.strokes, 3);
    });

    test('beyond +\$50 is the SNOWMAN, strokes scale and cap at 9', () {
      final snowman = run(212.87, par: 160);
      expect(snowman.verdict.name, 'SNOWMAN');
      expect(snowman.verdict.strokes, 5); // ceil(52.87/12)
      expect(run(1000).verdict.strokes, 9); // capped
    });

    test('colors: green under, ink par, red over', () {
      expect(run(130).verdict.color, VerdictColor.green);
      expect(run(150).verdict.color, VerdictColor.ink);
      expect(run(200).verdict.color, VerdictColor.red);
    });
  });

  group('sport reskins', () {
    test('same overage, different vocabulary per sport', () {
      for (final (sport, name) in [
        (SportSkin.football, 'PICK SIX'),
        (SportSkin.baseball, 'GOLDEN SOMBRERO'),
        (SportSkin.basketball, 'FOULED OUT'),
        (SportSkin.soccer, 'OWN GOAL'),
      ]) {
        final score = engine.score(
            sport: sport, par: 150, items: [item('cart', 260)]);
        expect(score.verdict.name, name);
        expect(score.verdict.headline, sport.headlines[6]);
      }
    });

    test('every sport has exactly 7 verdicts and 7 headlines', () {
      for (final sport in SportSkin.all) {
        expect(sport.verdicts.length, 7, reason: sport.key);
        expect(sport.headlines.length, 7, reason: sport.key);
      }
    });

    test('sport lookup falls back to golf', () {
      expect(SportSkin.byKey('cricket').key, 'golf');
      expect(SportSkin.byKey('soccer').key, 'soccer');
    });
  });

  group('mulligan', () {
    final items = [
      item('eggs', 7.99),
      item('kayak', 189.99, impulse: true),
      item('hoodie', 16.99, impulse: true),
    ];

    test('targets the priciest impulse item', () {
      expect(VerdictEngine.mulliganTargetOf(items)!.name, 'KAYAK');
    });

    test('striking the kayak turns a snowman into par', () {
      final before = engine.score(
          sport: SportSkin.golf, par: 210, items: items);
      expect(before.verdict.name, 'PAR'); // 214.97 vs 210
      final blowout = engine.score(
          sport: SportSkin.golf, par: 100, items: items);
      expect(blowout.verdict.name, 'SNOWMAN');
      final saved = engine.score(
          sport: SportSkin.golf,
          par: 100,
          items: items,
          mulliganUsed: true);
      expect(saved.finalTotal, closeTo(24.98, 0.001));
      expect(saved.verdict.name, 'EAGLE');
      expect(saved.liveImpulses.length, 1); // hoodie still on the record
    });

    test('no impulse items → no mulligan target', () {
      final clean = engine.score(
          sport: SportSkin.golf, par: 100, items: [item('eggs', 7.99)]);
      expect(clean.mulliganTarget, isNull);
    });
  });

  group('rating EMA', () {
    test('over-par rounds raise it, clean rounds decay it', () {
      var r = VerdictEngine.nextRating(0, 5); // bad round
      expect(r, 1.0);
      r = VerdictEngine.nextRating(r, 0); // clean
      expect(r, 0.9);
      // Under-par strokes never go negative into the rating.
      expect(VerdictEngine.nextRating(1.0, -2), 0.9);
      expect(VerdictEngine.nextRating(0, 0), 0);
    });
  });
}
