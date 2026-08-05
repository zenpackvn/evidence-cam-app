import Flutter
import UIKit

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
    // Cuộc gọi đến (kể cả Zalo/Messenger qua CallKit) — màn ghi hình cần biết
    // ngay lúc chuông reo, không đợi tới lúc bắt máy.
    CallObserverPlugin.register(
      with: engineBridge.pluginRegistry.registrar(forPlugin: "CallObserver")!
    )
  }
}
