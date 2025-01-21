import 'dart:io';
import 'package:flutter/material.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceMessageRecorder extends StatefulWidget {
  final String runnerId;
  final BuildContext scaffContext;

  const VoiceMessageRecorder(
      {super.key, required this.runnerId, required this.scaffContext});

  @override
  _VoiceMessageRecorderState createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder> {
  final AudioRecorder _record = AudioRecorder();
  FirebaseAuth auth = FirebaseAuth.instance;
  late User? currentUser;
  bool _isRecording = false;
  String? _filePath;

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${Uuid().v4()}.m4a';

    if (await _record.hasPermission()) {
      await _record.start(const RecordConfig(), path: filePath);

      setState(() {
        _isRecording = true;
        _filePath = filePath;
      });
    }
  }

  Future<void> _stopRecording() async {
    await _record.stop();

    setState(() {
      _isRecording = false;
    });

    if (_filePath != null) {
      await _uploadFileToFirebase(File(_filePath!));
    }
  }

  Future<void> _uploadFileToFirebase(File file) async {
    final storageRef = FirebaseStorage.instance.ref();
    final dbRef = FirebaseDatabase.instance
        .ref("users/${widget.runnerId}/voice_messages");
    final String fileName = const Uuid().v4();

    final fileRef = storageRef.child('voice_messages/$fileName.m4a');

    try {
      await fileRef.putFile(file);
      final downloadUrl = await fileRef.getDownloadURL();
      await dbRef.set({"voiceMessage": downloadUrl});
      ScaffoldMessenger.of(widget.scaffContext).showSnackBar(SnackBar(
        content: const Center(
            child: Text(
          "YOUR FRIEND HAS BEEN MOTIVATED",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        )),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: CustomColors().primaryGreen,
        margin: EdgeInsets.only(bottom: getHeight(widget.scaffContext) * 0.15,left: 20,right: 20),
      ));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(widget.scaffContext).showSnackBar(SnackBar(
        content: const Text(
          "OOPS,SOMETHING WENT WRONG",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: CustomColors().primaryRed,
        margin: EdgeInsets.only(bottom: getHeight(widget.scaffContext) * 0.15,left: 20,right: 20),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isRecording ? _stopRecording : _startRecording,
      icon: Icon(
        !_isRecording ? Icons.mic : Icons.stop,
        size: 30,
        color: !_isRecording
            ? CustomColors().primaryGreen
            : CustomColors().primaryRed,
      ),
    );
  }
}
