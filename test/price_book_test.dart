import 'package:flutter_test/flutter_test.dart';
import 'package:cartgolf/features/pricing/price_book.dart';

void main() {
  final book = PriceBook(
    guide: const {
      'eggs': 7.99,
      'paper towels': 21.99,
      'organic milk': 6.49,
      'rotisserie chicken': 4.99,
    },
    learned: const {'eggs': 6.79},
  );

  test('exact guide match fills the price', () {
    final est = book.estimate('paper towels')!;
    expect(est.price, 21.99);
    expect(est.learned, isFalse);
  });

  test('your own receipts beat the bundled guide', () {
    final est = book.estimate('eggs')!;
    expect(est.price, 6.79);
    expect(est.learned, isTrue);
  });

  test('fuzzy names still resolve', () {
    expect(book.estimate('Organic Milk 2pk')!.price, 6.49);
    expect(book.estimate('rotiserie chicken')!.price, 4.99); // typo
  });

  test('unknown items return null, never a wild guess', () {
    expect(book.estimate('plutonium'), isNull);
    expect(book.estimate(''), isNull);
  });
}
