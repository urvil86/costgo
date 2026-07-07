import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Register our channels once the Flutter view controller (and its engine)
    // exist. Deferred a runloop tick so the root VC is fully attached — the
    // implicit-engine callback's timing in the scene template is unreliable.
    DispatchQueue.main.async { [weak self] in
      guard
        let window = self?.window,
        let messenger = Self.flutterMessenger(in: window.rootViewController)
      else { return }
      AppDelegate.registerOcr(messenger: messenger)
      AppDelegate.registerSharedReceipt(messenger: messenger)
    }

    // Cold launch via a shared receipt file.
    for ctx in connectionOptions.urlContexts {
      AppDelegate.receiveSharedReceipt(url: ctx.url)
    }
  }

  // Warm: a receipt shared while the app is already running.
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for ctx in URLContexts {
      AppDelegate.receiveSharedReceipt(url: ctx.url)
    }
    super.scene(scene, openURLContexts: URLContexts)
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
