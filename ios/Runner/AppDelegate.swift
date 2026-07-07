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

    // On-device OCR via Apple Vision — free, private, on-device.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CostGoOcr") {
      AppDelegate.registerOcr(messenger: registrar.messenger())
    }
  }

  /// Idempotent: safe to call from both the implicit-engine callback and the
  /// SceneDelegate. Whichever runs first wins; the second is a harmless
  /// re-attach of the same handler. Belt-and-suspenders because the
  /// implicit-engine callback's timing in the scene-based template is
  /// finicky, and a missing channel = silent scan failures.
  static func registerOcr(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "costgo/ocr", binaryMessenger: messenger)
    channel.setMethodCallHandler(AppDelegate.handleOcr)
  }

  private static func handleOcr(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognizeText",
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
    else {
      result(FlutterError(
        code: "bad_args", message: "recognizeText requires an image path", details: nil))
      return
    }
    guard let image = loadCGImage(path: path) else {
      result(FlutterError(
        code: "bad_image", message: "Couldn't open that file as an image or PDF",
        details: nil))
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

  /// Loads a receipt as a CGImage — a normal image, or the first page of a
  /// PDF rendered at 2× (Costco digital receipts are often PDFs).
  private static func loadCGImage(path: String) -> CGImage? {
    if path.lowercased().hasSuffix(".pdf") {
      guard let doc = CGPDFDocument(URL(fileURLWithPath: path) as CFURL),
            let page = doc.page(at: 1) else { return nil }
      let box = page.getBoxRect(.mediaBox)
      let scale: CGFloat = 2
      let width = Int(box.width * scale)
      let height = Int(box.height * scale)
      guard width > 0, height > 0,
            let ctx = CGContext(
              data: nil, width: width, height: height, bitsPerComponent: 8,
              bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
      else { return nil }
      ctx.setFillColor(gray: 1, alpha: 1)
      ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
      ctx.scaleBy(x: scale, y: scale)
      ctx.drawPDFPage(page)
      return ctx.makeImage()
    }
    return UIImage(contentsOfFile: path)?.cgImage
  }

  // MARK: - Shared receipt (share-sheet "Copy to Cost-Go")

  /// A receipt file handed to us via the share sheet, waiting for Dart to
  /// pick it up. Held until Dart consumes it (covers cold launch, where the
  /// engine isn't ready to receive a push the instant the file arrives).
  static var pendingSharedReceipt: String?
  private static weak var sharedChannel: FlutterMethodChannel?

  static func registerSharedReceipt(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "costgo/shared_receipt", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      if call.method == "consumePending" {
        let path = pendingSharedReceipt
        pendingSharedReceipt = nil
        result(path)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    sharedChannel = channel
  }

  /// Called from the SceneDelegate when a receipt file is opened. Stash it
  /// and, if the engine is already up, nudge Dart to handle it now.
  static func receiveSharedReceipt(url: URL) {
    pendingSharedReceipt = url.path
    sharedChannel?.invokeMethod("receiptShared", arguments: url.path)
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
