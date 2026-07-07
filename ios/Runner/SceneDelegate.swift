import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    // Register the OCR channel here too: by the time the scene connects the
    // FlutterViewController and its engine exist, so this is the reliable
    // registration point regardless of implicit-engine callback timing.
    // Deferred a runloop tick so the root VC is fully attached.
    DispatchQueue.main.async { [weak self] in
      guard
        let window = self?.window,
        let messenger = Self.flutterMessenger(in: window.rootViewController)
      else { return }
      AppDelegate.registerOcr(messenger: messenger)
    }
  }

  private static func flutterMessenger(in root: UIViewController?)
    -> FlutterBinaryMessenger?
  {
    if let flutter = root as? FlutterViewController { return flutter.binaryMessenger }
    if let nav = root as? UINavigationController {
      return flutterMessenger(in: nav.viewControllers.first)
    }
    return flutterMessenger(in: root?.children.first)
  }
}
