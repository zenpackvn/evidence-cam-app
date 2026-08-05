import CallKit
import Flutter

/// Streams incoming-call events to Dart so the recording screen can pause
/// before the seller ever looks at the phone.
///
/// The app lifecycle alone cannot answer "is a call ringing?". A ringing call
/// and a message banner both put the app in `inactive`, and a VoIP call that
/// is never answered never backgrounds the app at all — which is exactly the
/// Zalo case that looked like nothing happened.
///
/// CallKit reports every call the system knows about, so carrier calls and
/// VoIP apps that adopt CallKit (Zalo, Messenger, WhatsApp) all arrive here
/// through the same path.
final class CallObserverPlugin: NSObject, FlutterStreamHandler, CXCallObserverDelegate {
  static let channelName = "zenpack/calls"

  private let observer = CXCallObserver()
  private var sink: FlutterEventSink?

  /// Calls already reported as ringing, so a state change on an unrelated call
  /// does not fire a second "incoming" for the same one.
  private var announced = Set<UUID>()

  /// Giữ sống cả plugin lẫn kênh cho tới hết vòng đời app.
  ///
  /// Bản trước để cả hai là biến cục bộ trong `register`. Hàm chạy xong là ARC
  /// giải phóng kênh, kênh thả luôn stream handler, và `CXCallObserver` mất
  /// delegate — cuộc gọi đến vẫn được hệ điều hành báo nhưng không còn ai nghe.
  /// Không lỗi, không cảnh báo, chỉ là im lặng.
  private static var retained: CallObserverPlugin?
  private static var channel: FlutterEventChannel?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = CallObserverPlugin()
    let channel = FlutterEventChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setStreamHandler(instance)
    instance.observer.setDelegate(instance, queue: nil)
    retained = instance
    self.channel = channel
  }

  func onListen(
    withArguments _: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    sink = events
    return nil
  }

  func onCancel(withArguments _: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  func callObserver(_: CXCallObserver, callChanged call: CXCall) {
    if call.hasEnded {
      announced.remove(call.uuid)
      sink?("ended")
      return
    }
    // `isOutgoing == false` and not yet connected means the phone is ringing.
    // Outgoing calls are the seller's own doing — interrupting their recording
    // for a call they placed themselves would only be confusing.
    guard !call.isOutgoing, !call.hasConnected else { return }
    guard announced.insert(call.uuid).inserted else { return }
    NSLog("[zenpack] cuoc goi den, sink=\(sink != nil)")
    sink?("incoming")
  }
}
