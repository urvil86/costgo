/// First launch: what this app is, who you are, how Frank should talk.
/// Three pages, no signup — everything stays on the phone, and the copy
/// says so out loud.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/news_theme.dart';
import '../features/roasts/frank.dart';
import '../features/sports/sport_skin.dart';
import '../game/game_controller.dart';
import 'brand.dart';
import 'widgets.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  final _name = TextEditingController();
  int _index = 0;
  String _sportKey = 'golf';
  RoastTone _tone = RoastTone.savage;

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _page.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsProvider);
    // Open on THE LIST tab so "build my first list" lands where it says.
    ref.read(shellTabProvider.notifier).state = 1;
    await ref.read(settingsProvider.notifier).update(settings.copyWith(
          onboarded: true,
          playerName: _name.text.trim(),
          sportKey: _sportKey,
          tone: _tone,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NewsInk.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _pageOne(),
                  _pageTwo(),
                  _pageThree(),
                ],
              ),
            ),
            // Dots + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 24,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          color: i == _index
                              ? NewsInk.mustard
                              : NewsInk.borderDim,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: InkButton(
                      onTap: _next,
                      color: NewsInk.red,
                      pressedColor: NewsInk.redDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _index < 2 ? 'NEXT' : 'BUILD MY FIRST LIST →',
                        style:
                            News.anton(17, color: NewsInk.paper, spacing: 2),
                      ),
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

  Widget _pad(Widget child) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8), child: child);

  Widget _pageOne() => _pad(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CostGoLogo(size: 34, dark: true),
          const Spacer(),
          Text('THE WAREHOUSE\nWINS BY DESIGN.',
              style: News.anton(42, color: NewsInk.paper, height: 1.05)),
          const SizedBox(height: 10),
          Text('THIS APP IS HOW YOU FIGHT BACK.',
              style: News.kicker(12, color: NewsInk.mustard)),
          const SizedBox(height: 28),
          for (final (n, text) in const [
            ('1', 'Make your list at home — prices fill in themselves.'),
            ('2', 'Shop. Check things off. Resist the ambushes.'),
            ('3', 'Scan the receipt at checkout.'),
            ('4', 'The Daily Cart scores the damage. Lower is better.'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: NewsInk.mustard, width: 2)),
                    child: Text(n,
                        style: News.mono(12,
                            color: NewsInk.mustard,
                            weight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: News.mono(13,
                            color: NewsInk.paper, height: 1.4)),
                  ),
                ],
              ),
            ),
          const Spacer(),
        ],
      ));

  Widget _pageTwo() => _pad(ListView(
        children: [
          Text('PICK YOUR SPORT',
              style: News.anton(34, color: NewsInk.paper)),
          const SizedBox(height: 6),
          Text(
              'Your trips get scored in its language — budgets become par, '
              'blowouts become fumbles. Change it anytime in Settings.',
              style:
                  News.mono(12, color: NewsInk.grayFaint, height: 1.5)),
          const SizedBox(height: 18),
          for (final sport in SportSkin.all)
            GestureDetector(
              onTap: () => setState(() => _sportKey = sport.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _sportKey == sport.key
                      ? NewsInk.mustard
                      : Colors.transparent,
                  border: Border.all(
                      color: _sportKey == sport.key
                          ? NewsInk.mustard
                          : NewsInk.borderDim,
                      width: 2),
                ),
                child: Row(
                  children: [
                    Text(sport.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sport.label,
                              style: News.mono(13,
                                  color: _sportKey == sport.key
                                      ? NewsInk.black
                                      : NewsInk.paper,
                                  weight: FontWeight.w700,
                                  spacing: 1)),
                          Text(
                              'Blow the budget → ${sport.verdicts.last}',
                              style: News.mono(10,
                                  color: _sportKey == sport.key
                                      ? NewsInk.gray
                                      : NewsInk.grayFaint)),
                        ],
                      ),
                    ),
                    if (_sportKey == sport.key)
                      const Icon(Icons.check_rounded,
                          color: NewsInk.black),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text('THE NAME ON YOUR SCORECARD (OPTIONAL)',
              style: News.kicker(10, color: NewsInk.mustard)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            style: News.mono(14, color: NewsInk.paper),
            cursorColor: NewsInk.mustard,
            decoration: InputDecoration(
              hintText: 'e.g. Alex',
              hintStyle: News.mono(13, color: NewsInk.borderDim),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: NewsInk.borderDim, width: 2),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: NewsInk.mustard, width: 2),
              ),
            ),
          ),
        ],
      ));

  Widget _pageThree() => _pad(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HOW HARD SHOULD\nYOUR PAPER GO?',
              style: News.anton(34, color: NewsInk.paper, height: 1.05)),
          const SizedBox(height: 6),
          Text('The Daily Cart reviews every trip you scan. Pick the editorial tone.',
              style: News.mono(12, color: NewsInk.grayFaint, height: 1.5)),
          const SizedBox(height: 20),
          for (final (tone, label, sample) in const [
            (RoastTone.savage, 'SAVAGE',
                '"You came for eggs and left dressed as the store."'),
            (RoastTone.deadpan, 'DEADPAN',
                '"Six pounds of gummy bears. Noted. Filed. Remembered."'),
            (RoastTone.gentle, 'GENTLE',
                '"The croissants happen to the best of us."'),
          ])
            GestureDetector(
              onTap: () => setState(() => _tone = tone),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      _tone == tone ? NewsInk.paper : Colors.transparent,
                  border: Border.all(
                      color:
                          _tone == tone ? NewsInk.paper : NewsInk.borderDim,
                      width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: News.kicker(11,
                            color: _tone == tone
                                ? NewsInk.red
                                : NewsInk.mustard)),
                    const SizedBox(height: 4),
                    Text(sample,
                        style: News.serifQuote(15,
                            color: _tone == tone
                                ? NewsInk.black
                                : NewsInk.paper)),
                  ],
                ),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.lock_rounded,
                  color: NewsInk.grayFaint, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    'NO ACCOUNT NEEDED. EVERYTHING STAYS ON THIS PHONE.',
                    style: News.mono(9,
                        color: NewsInk.grayFaint, spacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ));
}
