/// EVIDENCE COLLECTION → PARSE RESULTS.
///
/// Three intake paths: camera (real OCR), photo/screenshot (real OCR),
/// and "use tracked cart" (manual mode — score exactly what you tracked
/// in-store; also the dev-loop path with no camera).
library;

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/news_theme.dart';
import '../features/capture/ocr_service.dart';
import '../features/matching/receipt_parser.dart';
import '../game/game_controller.dart';
import 'widgets.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  static final bool _ocrAvailable = !kIsWeb && Platform.isIOS;

  Future<void> _snap(ImageSource source) async {
    final ctrl = ref.read(gameProvider.notifier);
    if (ref.read(gameProvider).snapping) return;
    ctrl.setSnapping(true);
    try {
      final picker = ImagePicker();
      final segments = <String>[];
      final ocr = VisionOcrService();
      while (true) {
        final shot =
            await picker.pickImage(source: source, imageQuality: 92);
        if (shot == null) break;
        segments.add(await ocr.recognizeFromImagePath(shot.path));
        if (!mounted) return;
        final more = await _askMoreSegments();
        if (more != true) break;
      }
      ocr.dispose();
      if (segments.isEmpty) return;
      await _ingest(stitchSegments(segments));
    } catch (e) {
      _toast('Scanner fell over: $e');
    } finally {
      if (mounted) ref.read(gameProvider.notifier).setSnapping(false);
    }
  }

  Future<bool?> _askMoreSegments() => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: NewsInk.paper,
          shape: const RoundedRectangleBorder(),
          title: Text('SEGMENT CAPTURED', style: News.anton(16)),
          content: Text(
              'Long receipt? Shoot the next section — overlap a little, '
              'the app stitches them.',
              style: News.mono(12, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('ADD SEGMENT', style: News.kicker(11)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("THAT'S ALL OF IT",
                  style: News.kicker(11, color: NewsInk.red)),
            ),
          ],
        ),
      );

  Future<void> _pasteText() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NewsInk.paper,
        shape: const RoundedRectangleBorder(),
        title: Text('PASTE RECEIPT TEXT', style: News.anton(16)),
        content: TextField(
          controller: controller,
          maxLines: 9,
          autofocus: true,
          style: News.mono(11),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: News.kicker(11)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('PARSE IT', style: News.kicker(11, color: NewsInk.red)),
          ),
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) await _ingest(text);
  }

  Future<void> _ingest(String ocrText) async {
    final listItems = ref.read(listItemsProvider).valueOrNull ?? [];
    final error = await ref
        .read(gameProvider.notifier)
        .ingestOcrText(ocrText, listItems);
    if (error != null) _toast(error);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: NewsInk.black,
      shape: const RoundedRectangleBorder(),
      content: Text(msg, style: News.mono(12, color: NewsInk.paper)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    return game.scanned ? _buildResults(game) : _buildCapture(game);
  }

  // ---- capture (dark) ----

  Widget _buildCapture(GameState game) {
    final ctrl = ref.read(gameProvider.notifier);
    final listItems = ref.watch(listItemsProvider).valueOrNull ?? [];

    return Container(
      color: NewsInk.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowHeader(
              dark: true,
              step: 'STEP 3 OF 4 — AT CHECKOUT',
              title: 'SCAN YOUR RECEIPT',
              onBack: ctrl.backToTrip,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('ON-DEVICE OCR · NOTHING LEAVES YOUR PHONE',
                        style: News.mono(11,
                            color: NewsInk.grayFaint, spacing: 1)),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: NewsInk.mustard, width: 2)),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Text('ALIGN RECEIPT',
                            style: News.mono(10,
                                color: NewsInk.mustard, spacing: 2)),
                      ),
                      Center(
                        child: Transform.rotate(
                          angle: 3 * 3.14159 / 180,
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: const BoxDecoration(
                              color: NewsInk.paper,
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0x80000000),
                                    blurRadius: 30,
                                    offset: Offset(0, 10)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                    child: Text('WHOLESALE',
                                        style: News.mono(9,
                                            weight: FontWeight.w700,
                                            spacing: 2))),
                                const Divider(color: NewsInk.black, height: 12),
                                Text('EGGS 2DZ .......... 7.99',
                                    style: News.mono(9, height: 1.7)),
                                Text('KS ORG MILK ....... 6.49',
                                    style: News.mono(9, height: 1.7)),
                                Text('GRND BEEF ........ 19.87',
                                    style: News.mono(9, height: 1.7)),
                                Text('▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒',
                                    style: News.mono(9,
                                        color: NewsInk.grayFaint,
                                        height: 1.7)),
                                Text('▒▒▒▒▒▒▒▒▒▒▒▒',
                                    style: News.mono(9,
                                        color: NewsInk.grayFaint,
                                        height: 1.7)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Camera OCR is Apple Vision — iOS only until Android
              // bring-up wires ML Kit natively. Android still scores via
              // paste text or the tracked cart.
              if (_ocrAvailable) ...[
                InkButton(
                  onTap: game.snapping
                      ? null
                      : () => _snap(ImageSource.camera),
                  color: NewsInk.mustard,
                  pressedColor: NewsInk.mustardHover,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                      game.snapping
                          ? 'DECODING KS ABBREVIATIONS…'
                          : '◉ SNAP RECEIPT',
                      style: News.anton(18, spacing: 2)),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (_ocrAvailable) ...[
                    Expanded(
                      child: InkButton(
                        onTap: () => _snap(ImageSource.gallery),
                        border: const Border.fromBorderSide(
                            BorderSide(color: NewsInk.grayFaint, width: 2)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text('FROM PHOTOS',
                            style: News.mono(10,
                                color: NewsInk.paper,
                                weight: FontWeight.w700,
                                spacing: 1)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: InkButton(
                      onTap: _pasteText,
                      color: _ocrAvailable ? null : NewsInk.mustard,
                      border: _ocrAvailable
                          ? const Border.fromBorderSide(
                              BorderSide(color: NewsInk.grayFaint, width: 2))
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text('PASTE RECEIPT TEXT',
                          style: News.mono(10,
                              color: _ocrAvailable
                                  ? NewsInk.paper
                                  : NewsInk.black,
                              weight: FontWeight.w700,
                              spacing: 1)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkButton(
                onTap: () => ctrl.useCartAsReceipt(listItems),
                border: const Border.fromBorderSide(
                    BorderSide(color: NewsInk.grayFaint, width: 2)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('NO RECEIPT — SCORE THE CART AS TRACKED',
                    style: News.mono(10,
                        color: NewsInk.grayFaint,
                        weight: FontWeight.w700,
                        spacing: 1)),
              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- results (light) ----

  Widget _buildResults(GameState game) {
    final ctrl = ref.read(gameProvider.notifier);
    final total =
        game.cartItems.fold(0.0, (s, i) => s + i.price);

    return Column(
      children: [
        Container(
          color: NewsInk.black,
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: FlowHeader(
              dark: true,
              step: 'STEP 3 OF 4 — CHECK THE READ',
              title: 'YOUR RECEIPT, DECODED',
              onBack: ctrl.rescan,
              trailing: Text(
                  '${game.parsedRows.length} ITEMS',
                  style: News.mono(10,
                      color: NewsInk.grayFaint, spacing: 1)),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            children: [
              if (game.scanWarnings.isNotEmpty)
                Container(
                  color: NewsInk.mustard,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    game.scanWarnings.join('\n'),
                    style: News.mono(10,
                        weight: FontWeight.w700, height: 1.5),
                  ),
                ),
              for (final (i, p) in game.parsedRows.indexed)
                PrintIn(
                  index: i,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: NewsInk.ruleDark,
                              width: 1,
                              style: BorderStyle.solid)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.raw,
                                style: News.mono(13,
                                    weight: FontWeight.w700)),
                            Text(money(p.price),
                                style: News.mono(13,
                                    weight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('→ ${p.full}',
                                  style: News.mono(11, color: NewsInk.gray)),
                            ),
                            Text(
                                p.impulse
                                    ? 'IMPULSE'
                                    : '${p.confidence}%',
                                style: News.mono(10,
                                    weight: FontWeight.w700,
                                    color: p.impulse
                                        ? NewsInk.red
                                        : p.confidence >= 92
                                            ? NewsInk.green
                                            : NewsInk.red)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL',
                        style: News.mono(14, weight: FontWeight.w700)),
                    Text('\$${money(total)}',
                        style: News.mono(14, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => ctrl.confirmScan(),
          child: Container(
            color: NewsInk.red,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text('CONFIRM & FACE JUDGMENT',
                    style: News.anton(17, color: NewsInk.paper, spacing: 2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
