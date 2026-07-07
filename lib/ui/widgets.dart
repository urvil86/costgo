/// Shared Daily Cart widgets: ink buttons, verdict stamps, the bottom tab
/// bar, blink/print/stamp animations from the prototype.
library;

import 'package:flutter/material.dart';

import '../core/theme/news_theme.dart';
import '../features/scoring/verdict_engine.dart';

Color verdictColor(VerdictColor c) => switch (c) {
      VerdictColor.green => NewsInk.green,
      VerdictColor.ink => NewsInk.black,
      VerdictColor.red => NewsInk.red,
    };

/// Flat pressable block — the design uses hover fills; on touch we flash the
/// pressed color.
class InkButton extends StatefulWidget {
  const InkButton({
    super.key,
    required this.onTap,
    required this.child,
    this.color,
    this.pressedColor,
    this.border,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color? color;
  final Color? pressedColor;
  final BoxBorder? border;
  final EdgeInsets padding;

  @override
  State<InkButton> createState() => _InkButtonState();
}

class _InkButtonState extends State<InkButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _down
              ? (widget.pressedColor ?? widget.color)
              : widget.color,
          border: widget.border,
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// Rubber-stamp entrance: rotate −8°, scale 2.4 → 0.92 → 1 with fade.
class Stamp extends StatelessWidget {
  const Stamp({
    super.key,
    required this.child,
    this.angleDegrees = -8,
    this.delay = Duration.zero,
  });

  final Widget child;
  final double angleDegrees;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500) + delay,
      curve: Interval(
        delay.inMilliseconds / (500 + delay.inMilliseconds),
        1,
        curve: Curves.easeOutBack,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.rotate(
          angle: angleDegrees * 3.14159 / 180,
          child:
              Transform.scale(scale: 2.4 - 1.4 * t.clamp(0, 1), child: child),
        ),
      ),
      child: child,
    );
  }
}

/// Newsprint row entrance: slide up 10px + fade, staggered by index.
class PrintIn extends StatelessWidget {
  const PrintIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delayMs = 60 * index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + delayMs),
      curve: Interval(delayMs / (300 + delayMs), 1, curve: Curves.easeOut),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// 1s steps(1) blink for live-status labels.
class Blink extends StatefulWidget {
  const Blink({super.key, required this.child});

  final Widget child;

  @override
  State<Blink> createState() => _BlinkState();
}

class _BlinkState extends State<Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) =>
            Opacity(opacity: _c.value < 0.5 ? 1 : 0.15, child: child),
        child: widget.child,
      );
}

/// Flow-screen header: back button, step label, screen title. Every trip
/// screen gets one — nobody is ever trapped.
class FlowHeader extends StatelessWidget {
  const FlowHeader({
    super.key,
    required this.step,
    required this.title,
    required this.onBack,
    this.dark = false,
    this.trailing,
  });

  /// "STEP 2 OF 4" style kicker.
  final String step;
  final String title;
  final VoidCallback onBack;
  final bool dark;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? NewsInk.paper : NewsInk.black;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 18, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_rounded, color: ink, size: 26),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step,
                    style: News.mono(9,
                        color: dark ? NewsInk.mustard : NewsInk.red,
                        weight: FontWeight.w700,
                        spacing: 2)),
                Text(title, style: News.anton(20, color: ink, spacing: 0.5)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Standard "are you sure" dialog in house style. Returns true on confirm.
Future<bool> confirmDialog(BuildContext context,
    {required String title,
    required String body,
    required String confirmLabel}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: NewsInk.paper,
      shape: const RoundedRectangleBorder(),
      title: Text(title, style: News.anton(18)),
      content: Text(body, style: News.mono(12, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('STAY', style: News.kicker(11)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel, style: News.kicker(11, color: NewsInk.red)),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Paper card with the standard soft ink shadow.
class PaperCard extends StatelessWidget {
  const PaperCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
            color: NewsInk.card, boxShadow: News.cardShadow),
        child: child,
      );
}

/// "MMM DD" date label, prototype style (JUN 28).
String newsDate(DateTime d) {
  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';
}

String money(double n) => n.toStringAsFixed(2);
