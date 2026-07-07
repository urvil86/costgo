/// STEP 1 — set your budget, then walk in. Dark takeover keeps the drama;
/// the words are plain English. Sport comes from Settings (with a shortcut
/// to change it), not a mid-flow decision.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/theme/news_theme.dart';
import '../game/game_controller.dart';
import 'settings_screen.dart';
import 'widgets.dart';

class StartTripScreen extends ConsumerStatefulWidget {
  const StartTripScreen({super.key});

  @override
  ConsumerState<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends ConsumerState<StartTripScreen> {
  /// Resolved "COSTCO TAMPA, FL · 0.4 MI AWAY", or a graceful shrug.
  String? _whereabouts;
  bool _locating = false;

  /// One-shot, foreground, only on tap — never background, never stored.
  Future<void> _locate() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(
            () => _whereabouts = 'NO LOCATION — NO PROBLEM. CARRY ON.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 10)),
      );
      final directory = await ref.read(warehouseDirectoryProvider.future);
      final hit = directory.nearestTo(position.latitude, position.longitude);
      if (hit == null) {
        setState(() => _whereabouts = 'NO WAREHOUSES ON FILE.');
        return;
      }
      final miles = hit.miles < 10
          ? hit.miles.toStringAsFixed(1)
          : hit.miles.toStringAsFixed(0);
      setState(() => _whereabouts =
          'COSTCO ${hit.warehouse.label} · $miles MI AWAY');
    } catch (_) {
      setState(
          () => _whereabouts = "COULDN'T GET A FIX. THE MISSION PROCEEDS.");
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final items = ref.watch(listItemsProvider).valueOrNull ?? [];
    final listTotal = items.fold(0.0, (s, i) => s + i.estPrice);
    final name = settings.playerName;

    return Container(
      color: NewsInk.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowHeader(
              dark: true,
              step: 'STEP 1 OF 4 — BEFORE YOU WALK IN',
              title: 'SET YOUR BUDGET',
              onBack: ctrl.cancelStartTrip,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                children: [
                  Blink(
                    child: Text('● TRIP STARTING',
                        style: News.kicker(11,
                            color: NewsInk.mustard, spacing: 3)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name.isEmpty
                        ? 'GOOD LUCK IN THERE.'
                        : 'GOOD LUCK IN THERE, ${name.toUpperCase()}.',
                    style:
                        News.anton(36, color: NewsInk.paper, height: 1.05),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Spend under this number and you win the round. '
                      'Every dollar over costs you.',
                      style: News.mono(12,
                          color: NewsInk.grayFaint, height: 1.5)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _locate,
                    child: Row(
                      children: [
                        Icon(
                            _whereabouts == null
                                ? Icons.location_searching_rounded
                                : Icons.location_on_rounded,
                            size: 14,
                            color: NewsInk.mustard),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locating
                                ? 'TRIANGULATING…'
                                : _whereabouts ??
                                    'WHICH WAREHOUSE? TAP TO CHECK',
                            style: News.mono(10,
                                color: NewsInk.mustard,
                                weight: FontWeight.w700,
                                spacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: NewsInk.paper,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'YOUR BUDGET — '
                            '${game.sport.parWord} IN ${game.sport.label} '
                            'TERMS',
                            style: News.kicker(10)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _Stepper(label: '−', onTap: ctrl.parDown),
                            Text('\$${game.par}', style: News.anton(48)),
                            _Stepper(label: '+', onTap: ctrl.parUp),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                            items.isEmpty
                                ? 'NO LIST — FREESTYLE ROUND. THE RECEIPT '
                                    'DECIDES; YOU MARK WHAT WAS PLANNED.'
                                : 'YOUR LIST ADDS UP TO '
                                    '\$${money(listTotal)} — LEAVE HEADROOM '
                                    'OR LIVE DANGEROUSLY.',
                            style: News.mono(10,
                                color: NewsInk.gray, spacing: 0.5)),
                        const SizedBox(height: 8),
                        Text(game.sport.ruleLine,
                            style: News.mono(10,
                                color: NewsInk.red,
                                spacing: 1,
                                weight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => openSettings(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(game.sport.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                            'SCORING AS ${game.sport.label} · CHANGE IN '
                            'SETTINGS',
                            style: News.mono(10,
                                color: NewsInk.grayFaint, spacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkButton(
                    onTap: () => ctrl.teeOff(),
                    color: NewsInk.red,
                    pressedColor: NewsInk.redDark,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    child: Column(
                      children: [
                        Text(game.sport.startLabel,
                            style: News.anton(20,
                                color: NewsInk.paper, spacing: 2)),
                        Text('START THE TRIP',
                            style: News.mono(9,
                                color: NewsInk.paper, spacing: 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              border: Border.all(color: NewsInk.black, width: 2)),
          alignment: Alignment.center,
          child:
              Text(label, style: News.mono(22, weight: FontWeight.w700)),
        ),
      );
}
