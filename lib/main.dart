import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/news_theme.dart';
import 'features/capture/ocr_service.dart';
import 'features/capture/shared_receipt.dart';
import 'game/game_controller.dart';
import 'ui/brand.dart';
import 'ui/front_page.dart';
import 'ui/list_tab.dart';
import 'ui/onboarding_screen.dart';
import 'ui/roast_screen.dart';
import 'ui/scan_screen.dart';
import 'ui/start_trip_screen.dart';
import 'ui/stats_screen.dart';
import 'ui/trip_screen.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: CostGoApp()));
}

class CostGoApp extends StatelessWidget {
  const CostGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cost-Go',
      theme: buildNewsTheme(),
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: const _Root(),
    );
  }
}

/// Splash → onboarding (first launch) → shell. Trip flow screens take over
/// the shell while a round is in progress. Also the entry point for receipts
/// shared in from other apps ("Copy to Cost-Go").
class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  // Held for the life of the app so the native share handler stays wired.
  // ignore: unused_field
  late final SharedReceiptChannel _shared;

  /// A shared receipt can land before settings finish loading; hold it until
  /// we're onboarded, then process once.
  String? _pendingSharedPath;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _shared = SharedReceiptChannel((path) {
      if (mounted) setState(() => _pendingSharedPath = path);
    });
  }

  Future<void> _processSharedReceipt(String path) async {
    _processing = true;
    final ocr = VisionOcrService();
    try {
      String text;
      try {
        text = await ocr.recognizeFromImagePath(path);
      } on OcrUnavailable {
        _sharedError('SCANNING NOT READY',
            'Text recognition isn\'t available here. Open the app and paste '
            'the receipt text instead.');
        return;
      } catch (e) {
        _sharedError('COULDN\'T READ THAT',
            'That file couldn\'t be read ($e). Try a clearer image, or paste '
            'the text in the app.');
        return;
      }
      if (text.trim().isEmpty) {
        _sharedError('NO TEXT FOUND',
            'No readable text in that file. Try a sharper receipt image.');
        return;
      }
      final err =
          await ref.read(gameProvider.notifier).ingestSharedReceiptText(text);
      if (err != null) _sharedError('COULDN\'T SCORE THAT', err);
    } finally {
      ocr.dispose();
      _processing = false;
    }
  }

  void _sharedError(String title, String body) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
      builder: (context) => AlertDialog(
        backgroundColor: NewsInk.paper,
        shape: const RoundedRectangleBorder(),
        title: Text(title, style: News.anton(18, color: NewsInk.red)),
        content: Text(body, style: News.mono(12, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: News.kicker(11, color: NewsInk.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // Once loaded + onboarded, drain any receipt shared into the app.
    if (settings.loaded &&
        settings.onboarded &&
        _pendingSharedPath != null &&
        !_processing) {
      final path = _pendingSharedPath!;
      _pendingSharedPath = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processSharedReceipt(path);
      });
    }

    if (!settings.loaded) {
      // Brand splash while persisted settings load (a few frames).
      return const Scaffold(
        backgroundColor: NewsInk.black,
        body: Center(child: CostGoLogo(size: 40, dark: true)),
      );
    }
    if (!settings.onboarded) return const OnboardingScreen();
    return const _Shell();
  }
}

class _Shell extends ConsumerWidget {
  const _Shell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(gameProvider.select((g) => g.screen));
    final tab = ref.watch(shellTabProvider);

    // A round in progress takes over the whole screen.
    if (screen != GameScreen.home) {
      return Scaffold(
        body: SafeArea(
          top: screen != GameScreen.startTrip && screen != GameScreen.scan,
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: switch (screen) {
              GameScreen.startTrip =>
                const StartTripScreen(key: ValueKey('start')),
              GameScreen.trip => const TripScreen(key: ValueKey('trip')),
              GameScreen.scan => const ScanScreen(key: ValueKey('scan')),
              GameScreen.roast => const RoastScreen(key: ValueKey('roast')),
              GameScreen.home => const SizedBox.shrink(),
            },
          ),
        ),
      );
    }

    final tabs = [
      const FrontPage(key: ValueKey('front')),
      const ListTab(key: ValueKey('list')),
      const StatsScreen(key: ValueKey('stats')),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: tabs[tab]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: NewsInk.card,
          border: Border(top: BorderSide(color: NewsInk.black, width: 3)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                for (final (i, label)
                    in const ['FRONT PAGE', 'THE LIST', 'STATS'].indexed)
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(shellTabProvider.notifier).state = i,
                      child: Container(
                        color:
                            tab == i ? NewsInk.black : Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(label,
                            style: News.anton(13,
                                color: tab == i
                                    ? NewsInk.paper
                                    : NewsInk.black,
                                spacing: 1)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
