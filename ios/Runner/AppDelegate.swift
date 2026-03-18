import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.todo_app/device_info"
  private let platformViewType = "com.example.todo_app/native_refresh_button"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let methodChannel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: controller.binaryMessenger
    )

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate unavailable", details: nil))
        return
      }

      switch call.method {
      case "getDeviceInfo":
        result(self.getDeviceInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let factory = NativeRefreshButtonViewFactory(methodChannel: methodChannel)
    registrar(forPlugin: "NativeRefreshButtonViewFactory")?.register(factory, withId: platformViewType)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getDeviceInfo() -> [String: Any] {
    UIDevice.current.isBatteryMonitoringEnabled = true

    let level = UIDevice.current.batteryLevel
    let batteryLevel = level >= 0 ? Int(level * 100) : -1

    let batteryState = UIDevice.current.batteryState
    let isCharging = batteryState == .charging || batteryState == .full

    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [.withInternetDateTime]
    let systemTime = formatter.string(from: Date())

    return [
      "batteryLevel": batteryLevel,
      "deviceModel": UIDevice.current.model,
      "isCharging": isCharging,
      "systemTime": systemTime,
    ]
  }
}

final class NativeRefreshButtonViewFactory: NSObject, FlutterPlatformViewFactory {
  private let methodChannel: FlutterMethodChannel

  init(methodChannel: FlutterMethodChannel) {
    self.methodChannel = methodChannel
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeRefreshButtonView(frame: frame, methodChannel: methodChannel)
  }
}

final class NativeRefreshButtonView: NSObject, FlutterPlatformView {
  private let button: UIButton
  private let methodChannel: FlutterMethodChannel

  init(frame: CGRect, methodChannel: FlutterMethodChannel) {
    self.button = UIButton(type: .system)
    self.methodChannel = methodChannel
    super.init()

    button.frame = frame
    button.setTitle("Native Refresh Battery", for: .normal)
    button.backgroundColor = UIColor.systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
  }

  func view() -> UIView {
    button
  }

  @objc private func onTap() {
    methodChannel.invokeMethod("nativeButtonPressed", arguments: nil)
  }
}
