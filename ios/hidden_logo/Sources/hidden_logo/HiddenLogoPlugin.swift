import Flutter
import UIKit

public class HiddenLogoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "hidden_logo",
            binaryMessenger: registrar.messenger()
        )
        let instance = HiddenLogoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getMachineIdentifier":
            result(getMachineIdentifier())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getMachineIdentifier() -> String? {
        if let simulatorModelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }

        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafeBytes(of: &systemInfo.machine) { rawBuffer -> String? in
            let buffer = rawBuffer.bindMemory(to: CChar.self)
            guard let baseAddress = buffer.baseAddress else { return nil }
            return String(validatingUTF8: baseAddress)
        }
        return machine
    }
}
