import 'package:flutter_test/flutter_test.dart';
import 'package:cartgolf/features/roasts/frank.dart';
import 'package:cartgolf/features/scoring/verdict_engine.dart';
import 'package:cartgolf/features/sports/sport_skin.dart';

CartItem item(String name, double price, {bool impulse = false}) => CartItem(
    name: name.toUpperCase(), fullName: name, price: price, impulse: impulse);

void main() {
  const engine = VerdictEngine();

  TripScore score(List<CartItem> items,
          {int par = 150, bool mulligan = false}) =>
      engine.score(
          sport: SportSkin.golf,
          par: par,
          items: items,
          mulliganUsed: mulligan);

  test('under par earns grudging respect, never a roast', () {
    final s = score([item('eggs', 100)]);
    for (final tone in RoastTone.values) {
      final q = Frank(tone: tone).quote(s);
      expect(q, isNotEmpty);
      expect(q.contains('{item}'), isFalse);
    }
  });

  test('on par gets the suspicious-professional treatment', () {
    final s = score([item('eggs', 150)]);
    expect(Frank(tone: RoastTone.savage).quote(s), contains('par'));
  });

  test('worst surviving impulse item gets named in the roast', () {
    final s = score([
      item('eggs', 20),
      item('Inflatable Kayak', 189.99, impulse: true),
    ]);
    final q = Frank(tone: RoastTone.savage).quote(s);
    expect(q.toLowerCase(), contains('inflatable kayak'));
  });

  test('bespoke temptation roast wins in savage mode', () {
    final s = score([item('LED Patio Lights', 34.99, impulse: true)],
        par: 20);
    final q = Frank(tone: RoastTone.savage).quote(s,
        bespokeRoast:
            'Patio lights for a residence that has no patio. Bold.');
    expect(q, startsWith('Patio lights'));
  });

  test('deadpan stays clinical even for a kayak', () {
    final s = score([item('kayak', 189.99, impulse: true)], par: 20);
    final q = Frank(tone: RoastTone.deadpan).quote(s);
    expect(q.length, lessThan(80));
  });

  test('mulligan-stricken item cannot be roasted', () {
    final s = score([
      item('eggs', 200), // keeps the round over par
      item('kayak', 189.99, impulse: true),
      item('hoodie', 16.99, impulse: true),
    ], mulligan: true);
    final q = Frank(tone: RoastTone.savage).quote(s);
    expect(q.toLowerCase(), isNot(contains('kayak')));
    expect(q.toLowerCase(), contains('hoodie'));
  });

  test('over par with a clean list blames the prices', () {
    final s = score([item('eggs', 200)]);
    final q = Frank(tone: RoastTone.savage).quote(s);
    expect(q.toLowerCase(),
        anyOf(contains('prices'), contains('inflation'), contains('warehouse')));
  });

  test('seed varies the pull without repeating slots', () {
    final s = score([item('eggs', 200)]);
    const frank = Frank(tone: RoastTone.savage);
    final quotes = {for (var i = 0; i < 3; i++) frank.quote(s, seed: i)};
    expect(quotes.length, greaterThan(1));
  });

  test('temptations deck json shape parses', () {
    final t = Temptation.fromJson(const {
      'name': 'GUMMI BEARS 6LB',
      'full': 'Gummy Bears, 6 lb',
      'price': 12.99,
      'tease': 'tease',
      'roast': 'roast',
    });
    final cartItem = t.toCartItem();
    expect(cartItem.impulse, isTrue);
    expect(cartItem.price, 12.99);
  });
}
