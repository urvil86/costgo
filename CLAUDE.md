# Cost-Go — THE DAILY CART

On-device Flutter app that scores Costco trips like sport. Par is your trip
budget in dollars; the receipt decides the verdict; Frank (Senior Warehouse
Correspondent) writes the roast. Vintage-newspaper design. Design source of
truth: `/Users/urvilshah/dev/costco/Cost-Go App.html` (interactive prototype —
colors, copy, animations, and scoring rules all come from it).

## Hard constraints — do not violate
- **Zero server costs.** No backend, no accounts, no cloud DB, no hosted AI.
- **No paid APIs.** OCR is ML Kit on-device; geofencing native; roasts are
  local templates.
- **Privacy by default.** No analytics/ad SDKs. Nothing leaves the phone.
- "Costco" must never appear in the app name or icon (unaffiliated).
- Fonts are bundled TTFs (assets/fonts) — never fetch fonts at runtime.

## The game & IA (post UX-rework 2026-07-06)
- Flow: onboarding (3 pages: brand+loop / sport+name / tone) → 3-tab shell:
  FRONT PAGE (default) / THE LIST ("I'M AT COSTCO" CTA) / STATS. Signing a
  card jumps to FRONT PAGE; finishing onboarding jumps to THE LIST. Trip flow
  takes over the shell: set budget → live trip → scan → verdict → sign.
  Every flow screen has a back affordance (FlowHeader); abandoning or
  discarding never scores anything.
- NEVER show the word "geofence" in UI copy. Starting a trip is a manual
  button; location prompts are a future opt-in, described in plain English.
- Sport, tone, and player name live in SETTINGS (gear on every tab); they
  apply to future trips only. No accounts by design — local profile is the
  privacy pitch, don't add auth.
- Sports: golf / football / baseball / hoops / soccer. Each `SportSkin`
  reskins EVERYTHING (trip word, par word, rating label, start/mulligan
  labels, rule line, chart label, 7 verdicts, 7 headlines).
  `lib/features/sports/sport_skin.dart`.
- Verdict tiers by dollars over par (`lib/features/scoring/verdict_engine.dart`):
  ≤−20 tier0 · <−5 tier1 · ≤5 tier2 · ≤15 tier3 · ≤30 tier4 · ≤50 tier5 ·
  else tier6. Strokes −2/−1/0/+1/+2/+3/ceil(over/12) capped 9.
- Mulligan (sport-named) strikes the priciest impulse item, once per trip.
- Ledger entries FREEZE their verdict wording at sign-time (sportKey,
  tripWord, parWord stored per row). Never rewrite history.
- Rating EMA: `(rating*9 + max(0,strokes)*2)/10`, floor 0.
- The $1.50 hot dog never counts. Gas and food-court receipts are never
  scored.
- Freestyle rounds: empty list is allowed — every receipt item arrives
  UNPLANNED and the user taps rows on the scan-results screen to flip
  planned ↔ unplanned (same tap fixes OCR mis-matches on normal rounds).
- Tones: savage (default) / deadpan / gentle — `lib/features/roasts/frank.dart`
  plus bespoke roasts in `assets/temptations.json`. NO mascot in UI copy:
  the voice is THE DAILY CART; the quote byline is the USER'S name.
- List prices auto-fill: `assets/price_guide.json` (bundled guide) +
  `LearnedPrices` drift table (real prices captured when a card is signed;
  learned beats guide). `lib/features/pricing/price_book.dart`.

## Architecture
- `lib/game/game_controller.dart` — Riverpod trip-flow machine
  (home/startTrip/trip/scan/roast) + persistence; tabs live in main.dart.
- `lib/ui/*` — one file per screen + `widgets.dart` (InkButton, FlowHeader,
  confirmDialog, Stamp, PrintIn, Blink, PaperCard) + `brand.dart`
  (CostGoLogo). Palette/type: `NewsInk`/`News` in
  `lib/core/theme/news_theme.dart` (class is NewsInk because Material owns
  `Ink`).
- `lib/features/matching/` — receipt parser (data-driven rules), alias
  dictionary, fuzzy matcher. Pure Dart, no Flutter imports. OCR adapter in
  `lib/features/capture/ocr_service.dart`.
- Drift schema `lib/data/db/database.dart`; codegen:
  `dart run build_runner build --delete-conflicting-outputs`.

## Testing
`flutter test` must stay green. Suite includes an end-to-end widget test
(`test/full_round_test.dart`) that plays a whole round. Rules for widget
tests here, each learned the hard way:
- Never `pumpAndSettle` — the start-trip screen has an infinite blink
  animation; use fixed-duration pumps.
- Never await `rootBundle` loads inside `testWidgets` (FakeAsync) — override
  asset-backed providers (e.g. `temptationsDeckProvider`) instead, or the
  test hangs to its 10-minute timeout.
- Never `addTearDown(db.close)` for a drift DB in `testWidgets` — close
  awaits stream-cleanup timers nothing pumps after the body returns (hang).
  Instead end the test with `pumpWidget(SizedBox())` + two
  `pump(Duration(milliseconds: 1))` so drift's zero-duration cleanup timers
  fire before the pending-timer invariant check.

⚠️ Parser fixtures are SYNTHETIC; validate against 10–15 real Costco
receipts before trusting the parser (open item #1).

## Open items
1. Real receipt corpus for parser fixtures.
2. `assets/costco_locations.json` — compile once from Costco's public
   locator (~600 US warehouses); never scrape at runtime. Then real geofence
   registration (nearest 20, ~250 m radius) replaces SIMULATE button.
3. Share-card image generation (score + verdict stamp + Frank quote).
4. App name/trademark check before store submission.

## Toolchain
Flutter SDK at `~/development/flutter` (add `~/development/flutter/bin` to
PATH). No Xcode/Android Studio on this machine — `flutter test`/`analyze`
work; device builds need those installed.
