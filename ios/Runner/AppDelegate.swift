import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // On-device OCR via Apple Vision — free, private, arm64-simulator-native.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CostGoOcr") {
      let channel = FlutterMethodChannel(
        name: "costgo/ocr", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler(AppDelegate.handleOcr)
    }
  }

  private static func handleOcr(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognizeText",
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String,
          let image = UIImage(contentsOfFile: path)?.cgImage
    else {
      result(FlutterError(
        code: "bad_args", message: "recognizeText requires an image path", details: nil))
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let request = VNRecognizeTextRequest { req, err in
        if let err = err {
          DispatchQueue.main.async {
            result(FlutterError(code: "ocr_failed", message: err.localizedDescription, details: nil))
          }
          return
        }
        let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
        DispatchQueue.main.async { result(AppDelegate.assembleLines(observations)) }
      }
      request.recognitionLevel = .accurate
      // Receipts are codes and abbreviations, not prose — autocorrect hurts.
      request.usesLanguageCorrection = false

      let handler = VNImageRequestHandler(cgImage: image, options: [:])
      do {
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  /// Vision returns fragments (a receipt row often splits into name-left,
  /// price-right). Group fragments whose vertical centers overlap into one
  /// row, order rows top-to-bottom and fragments left-to-right, so the Dart
  /// parser sees `CODE NAME PRICE` on a single line.
  private static func assembleLines(_ observations: [VNRecognizedTextObservation]) -> String {
    struct Fragment {
      let text: String
      let box: CGRect  // Vision: origin bottom-left, normalized
    }
    let fragments: [Fragment] = observations.compactMap { obs in
      guard let candidate = obs.topCandidates(1).first else { return nil }
      return Fragment(text: candidate.string, box: obs.boundingBox)
    }

    var rows: [[Fragment]] = []
    // Top of image = high Y in Vision coordinates.
    for fragment in fragments.sorted(by: { $0.box.midY > $1.box.midY }) {
      if let last = rows.last,
         let anchor = last.first,
         abs(anchor.box.midY - fragment.box.midY)
           < max(anchor.box.height, fragment.box.height) * 0.6 {
        rows[rows.count - 1].append(fragment)
      } else {
        rows.append([fragment])
      }
    }
    return rows
      .map { row in
        row.sorted(by: { $0.box.minX < $1.box.minX })
          .map(\.text)
          .joined(separator: " ")
      }
      .joined(separator: "\n")
  }
}
