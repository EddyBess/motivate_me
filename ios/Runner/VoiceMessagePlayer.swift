import AVFoundation

class VoiceMessagePlayer: NSObject, FlutterPlugin {
    private var player: AVPlayer?
    private var playerObserver: Any?
    private var audioSession: AVAudioSession?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "voiceMessagePlayer", binaryMessenger: registrar.messenger())
        let instance = VoiceMessagePlayer()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "playVoiceMessage", let args = call.arguments as? [String: Any], let url = args["url"] as? String {
            playVoiceMessage(url: url, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func playVoiceMessage(url: String, result: @escaping FlutterResult) {
        guard let audioUrl = URL(string: url) else {
            result(FlutterError(code: "INVALID_URL", message: "URL not valid", details: nil))
            return
        }

        // Set up audio session for playback
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession?.setActive(true)
        } catch {
            result(FlutterError(code: "SESSION_ERROR", message: error.localizedDescription, details: nil))
            return
        }

        // Initialize player and start playback
        player = AVPlayer(url: audioUrl)

        // Add observer for when playback finishes
        playerObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) { [weak self] time in
            if let currentItem = self?.player?.currentItem, currentItem.status == .readyToPlay, CMTimeCompare(currentItem.duration, time) == 0 {
                try? self?.audioSession?.setCategory(.ambient, mode: .default, options: [])
                try? self?.audioSession?.setActive(false)
            }
        }

        player?.play()
        result(nil)
    }

    deinit {
        if let playerObserver = playerObserver {
            player?.removeTimeObserver(playerObserver)
        }
        player?.removeObserver(self, forKeyPath: "status")
    }
}
