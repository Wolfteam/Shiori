import Flutter
import UIKit
import WebKit

class SceneDelegate: FlutterSceneDelegate {

    var webView: WKWebView?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "com.github.wolfteam.shiori",
                binaryMessenger: controller.binaryMessenger)
            channel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                self?.methodChannelHandler(call, result: result)
            })
        }
    }

    public func methodChannelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint(call.method)
        switch call.method {
        case "getWebViewUserAgent":
            let userAgent = getWebViewUserAgent()
            result(userAgent)
        default:
            result(FlutterMethodNotImplemented)
            return
        }
        result(nil)
    }

    private func getWebViewUserAgent() -> String? {
        let webConfiguration = WKWebViewConfiguration()
        if webView == nil {
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
        }
        return webView!.value(forKey: "userAgent") as? String ?? ""
    }
}
