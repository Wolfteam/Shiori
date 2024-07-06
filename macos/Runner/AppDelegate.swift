import Cocoa
import FlutterMacOS

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
        default:
            result(FlutterMethodNotImplemented);
            return
        }
        result(nil);
    }
}
