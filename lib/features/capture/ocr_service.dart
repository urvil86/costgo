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

/// Thrown when the platform OCR channel isn't wired up (unsupported platform,
/// or the native channel failed to register). The UI catches this and routes
/// the user to the always-available paste path.
class OcrUnavailable implements Exception {
  const OcrUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

class VisionOcrService implements OcrService {
  static const _channel = MethodChannel('costgo/ocr');

  @override
  Future<String> recognizeFromImagePath(String imagePath) async {
    if (!Platform.isIOS) {
      throw const OcrUnavailable('OCR is iOS-only for now.');
    }
    try {
      final text = await _channel
          .invokeMethod<String>('recognizeText', {'path': imagePath});
      return text ?? '';
    } on MissingPluginException {
      // The native channel never registered — treat as unavailable so the
      // UI offers paste instead of surfacing a cryptic error.
      throw const OcrUnavailable('OCR channel not registered.');
    }
  }

  void dispose() {}
}
