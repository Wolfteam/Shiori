import Cocoa
import FlutterMacOS
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        let channel = FlutterMethodChannel.init(name: "com.github.wolfteam.shiori", binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.methodChannelHandler(call, result: result)
        })
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
