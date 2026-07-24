# Native Side — Swift (iOS)

Swift handlers for MethodChannel and EventChannel. Register in `AppDelegate.swift`.

## `ios/Runner/Channels/AppMethodChannelHandler.swift`

```swift
import Flutter
import UIKit

class AppMethodChannelHandler {
    static let channelName = "com.example.app/battery"

    private var channel: FlutterMethodChannel?

    func register(with messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
        channel?.setMethodCallHandler(handle)
    }

    func unregister() {
        channel?.setMethodCallHandler(nil)
        channel = nil
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getBatteryLevel":
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = Int(UIDevice.current.batteryLevel * 100)
            if level >= 0 {
                result(level)
            } else {
                result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
```

## `ios/Runner/Channels/AppEventChannelHandler.swift`

```swift
import Flutter
import CoreMotion

class AppEventChannelHandler: NSObject, FlutterStreamHandler {
    static let channelName = "com.example.app/sensors"

    private var eventChannel: FlutterEventChannel?
    private let motionManager = CMMotionManager()

    func register(with messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(name: Self.channelName, binaryMessenger: messenger)
        eventChannel?.setStreamHandler(self)
    }

    func unregister() {
        eventChannel?.setStreamHandler(nil)
        eventChannel = nil
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard motionManager.isAccelerometerAvailable else {
            return FlutterError(code: "UNAVAILABLE", message: "Accelerometer not available", details: nil)
        }
        motionManager.accelerometerUpdateInterval = 1.0 / 30.0
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                events(FlutterError(code: "SENSOR_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            if let data = data {
                events([
                    "x": data.acceleration.x,
                    "y": data.acceleration.y,
                    "z": data.acceleration.z,
                ])
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        return nil
    }
}
```

## Register in `AppDelegate.swift`

```swift
@main
@objc class AppDelegate: FlutterAppDelegate {
    private let methodHandler = AppMethodChannelHandler()
    private let eventHandler = AppEventChannelHandler()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        methodHandler.register(with: controller.binaryMessenger)
        eventHandler.register(with: controller.binaryMessenger)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```
