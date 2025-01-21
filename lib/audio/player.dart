import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String runnerId;
  const VoiceMessagePlayer({Key? key, required this.runnerId}) : super(key: key);

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  FirebaseDatabase db = FirebaseDatabase.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late DatabaseReference ref;
  String lastPlayedMessage = "";
  
  static const MethodChannel _channel = MethodChannel('voiceMessagePlayer');

  @override
  void initState() {
    super.initState();
    ref = db.ref("users/${widget.runnerId}/voice_messages");
    _startListeningForVoiceMessage();
  }

  void _startListeningForVoiceMessage() {
    ref.onValue.listen((event) async {
      var data = event.snapshot.value as Map?;
      final newVoiceMessage = data?["voiceMessage"];
      
      if (newVoiceMessage != null && newVoiceMessage != "" && newVoiceMessage != lastPlayedMessage) {
        lastPlayedMessage = newVoiceMessage;
        try {
          await _channel.invokeMethod('playVoiceMessage', {"url": newVoiceMessage});
          ref.set({"voiceMessage":""});
        } on PlatformException catch (e) {
          print("Failed to play audio: ${e.message}");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
