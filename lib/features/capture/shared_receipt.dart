/// Bridges the native "Copy to Cost-Go" share into the app.
///
/// Two arrival paths, both handled: a cold launch (the file is waiting when
/// the engine boots — pulled via `consumePending`) and a warm share (native
/// pushes `receiptShared` while the app runs). Either way we hand the file
/// path to a single callback.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class SharedReceiptChannel {
  SharedReceiptChannel(this._onPath) {
    if (!Platform.isIOS) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'receiptShared' && call.arguments is String) {
        _onPath(call.arguments as String);
      }
    });
    // Drain anything that arrived during a cold launch.
    _drainPending();
  }

  static const _channel = MethodChannel('costgo/shared_receipt');
  final void Function(String path) _onPath;

  Future<void> _drainPending() async {
    try {
      final path = await _channel.invokeMethod<String>('consumePending');
      if (path != null && path.isNotEmpty) _onPath(path);
    } on MissingPluginException {
      // Channel not wired (e.g. non-iOS) — nothing to drain.
    }
  }
}
