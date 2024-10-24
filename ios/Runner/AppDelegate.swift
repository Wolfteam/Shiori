import UIKit
import Flutter
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var webView: WKWebView?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.github.wolfteam.shiori", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.methodChannelHandler(call, result: result)
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    public func methodChannelHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        debugPrint(call.method)
        switch call.method {
        case "getWebViewUserAgent":
            let userAgent = getWebViewUserAgent()
            result(userAgent)
        default:
            result(FlutterMethodNotImplemented);
            return
        }
        result(nil);
    }
    
    private func getWebViewUserAgent() -> String? {
        let webConfiguration = WKWebViewConfiguration()
        if (webView == nil) {
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
        }
        return webView!.value(forKey: "userAgent") as? String ?? ""
    }
}
