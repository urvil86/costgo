import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/news_theme.dart';
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
      home: const _Root(),
    );
  }
}

/// Splash → onboarding (first launch) → shell. Trip flow screens take over
/// the shell while a round is in progress.
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
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
