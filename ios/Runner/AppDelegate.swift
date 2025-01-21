import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register VoiceMessagePlayer channel
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let voiceMessageChannel = FlutterMethodChannel(name: "voiceMessagePlayer", binaryMessenger: controller.binaryMessenger)
        
        // Instantiate and set the method call handler for VoiceMessagePlayer
        let voiceMessagePlayer = VoiceMessagePlayer()
        voiceMessageChannel.setMethodCallHandler(voiceMessagePlayer.handle)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
