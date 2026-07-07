/// Cost-Go brand lockup — a price-tag cart mark plus the Anton wordmark.
/// Drawn in code so the brand ships with zero binary assets.
library;

import 'package:flutter/material.dart';

import '../core/theme/news_theme.dart';

class CostGoLogo extends StatelessWidget {
  const CostGoLogo({super.key, this.size = 28, this.dark = false});

  /// Wordmark cap-height in logical pixels.
  final double size;

  /// True on dark backgrounds (paper-colored text).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? NewsInk.paper : NewsInk.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(size * 1.15, size * 1.15),
          painter: _CartTagPainter(ink: ink),
        ),
        SizedBox(width: size * 0.3),
        Text.rich(
          TextSpan(
            text: 'COST',
            style: News.anton(size * 1.35, color: ink, spacing: 0.5),
            children: [
              TextSpan(
                  text: '-GO',
                  style:
                      News.anton(size * 1.35, color: NewsInk.red, spacing: 0.5)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A shopping cart whose basket is a price tag — get in, get out, on budget.
class _CartTagPainter extends CustomPainter {
  const _CartTagPainter({required this.ink});

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fillRed = Paint()..color = NewsInk.red;

    // Basket (price-tag shape: rectangle with a clipped corner).
    final basket = Path()
      ..moveTo(w * 0.18, h * 0.22)
      ..lineTo(w * 0.78, h * 0.22)
      ..lineTo(w * 0.92, h * 0.40)
      ..lineTo(w * 0.80, h * 0.62)
      ..lineTo(w * 0.28, h * 0.62)
      ..close();
    canvas.drawPath(basket, fillRed);
    canvas.drawPath(basket, stroke..color = ink);

    // Tag hole.
    canvas.drawCircle(
        Offset(w * 0.72, h * 0.34), w * 0.045, Paint()..color = NewsInk.paper);

    // Cart handle.
    canvas.drawLine(Offset(w * 0.05, h * 0.10), Offset(w * 0.18, h * 0.22),
        stroke..color = ink);

    // Wheels.
    final wheel = Paint()..color = ink;
    canvas.drawCircle(Offset(w * 0.36, h * 0.80), w * 0.08, wheel);
    canvas.drawCircle(Offset(w * 0.70, h * 0.80), w * 0.08, wheel);
  }

  @override
  bool shouldRepaint(covariant _CartTagPainter oldDelegate) =>
      oldDelegate.ink != ink;
}
