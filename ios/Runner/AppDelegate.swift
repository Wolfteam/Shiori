import UIKit
import Flutter
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
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
        case "start":
            guard let args: [String: Any] = (call.arguments as? [String: Any]) else {
                result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (start)") )
                return
            }
            
            let secret = args["secret"] as! String
            AppCenter.start(withAppSecret: secret, services: [
                Analytics.self,
                Crashes.self,
            ])
        case "trackEvent":
            trackEvent(call: call, result: result)
            return
        case "getInstallId":
            result(AppCenter.installId.uuidString)
            return
        case "isCrashesEnabled":
            result(Crashes.enabled)
            return
        case "configureCrashes":
            Crashes.enabled = call.arguments as! Bool
        case "isAnalyticsEnabled":
            result(Analytics.enabled)
            return
        case "configureAnalytics":
            Analytics.enabled = call.arguments as! Bool
        default:
            result(FlutterMethodNotImplemented);
            return
        }
        result(nil);
    }
    
    private func trackEvent(call: FlutterMethodCall, result: FlutterResult) {
        guard let args:[String: Any] = (call.arguments as? [String: Any]) else {
            result(FlutterError(code: "400", message:  "Bad arguments", details: "iOS could not recognize flutter arguments in method: (trackEvent)") )
            return
        }
        
        let name = args["name"] as? String
        let properties = args["properties"] as? [String: String]
        if(name != nil) {
            Analytics.trackEvent(name!, withProperties: properties)
        }
        
        result(nil)
    }
}
