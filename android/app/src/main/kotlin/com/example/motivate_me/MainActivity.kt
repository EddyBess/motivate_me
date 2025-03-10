package com.example.motivate_me

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register VoiceMessagePlayerPlugin
        flutterEngine.plugins.add(VoiceMessagePlayerPlugin())
    }
}
