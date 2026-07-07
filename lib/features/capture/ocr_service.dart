/// On-device OCR. iOS: Apple Vision via a tiny platform channel — free,
/// arm64-simulator-native, nothing leaves the phone. (ML Kit was dropped on
/// iOS: Google ships no arm64-simulator slices and the iOS 26 simulator no
/// longer runs x86_64 apps.) Android: wire ML Kit natively at Android
/// bring-up — until then OCR reports unsupported and the paste/manual paths
/// carry the flow.
///
/// Kept behind an interface so tests and the desktop dev loop can inject
/// text without a camera. Multi-shot stitching lives in the parser layer
/// (`stitchSegments`).
library;

import 'dart:io';

import 'package:flutter/services.dart';

abstract interface class OcrService {
  Future<String> recognizeFromImagePath(String imagePath);
}

class VisionOcrService implements OcrService {
  static const _channel = MethodChannel('costgo/ocr');

  @override
  Future<String> recognizeFromImagePath(String imagePath) async {
    if (!Platform.isIOS) {
      throw UnsupportedError(
          'OCR is iOS-only for now — use paste text or manual mode.');
    }
    final text = await _channel
        .invokeMethod<String>('recognizeText', {'path': imagePath});
    return text ?? '';
  }

  void dispose() {}
}
