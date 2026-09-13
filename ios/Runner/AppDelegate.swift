import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    //Registering here rather than in didFinishLaunchingWithOptions is what the scene based
    //template requires: registering against the app delegate forces the implicit engine to be
    //created early, so the scene later finds it already invoked and shows a black window
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
