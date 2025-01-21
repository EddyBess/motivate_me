import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:motivate_me/utils/permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:motivate_me/services/userService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OnboardingForm extends StatefulWidget {
  final String userId;
  final String? initialUsername;

  const OnboardingForm({super.key, required this.userId, this.initialUsername});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  DateTime? _birthDate;
  String? _gender;
  String? _runFrequency;

  final TextEditingController _usernameController = TextEditingController();
  final Authservice _authService = Authservice();

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialUsername != null) {
      _usernameController.text = widget.initialUsername!;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    if (Platform.isIOS) {
      DateTime? tempDate;
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 250,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime(2000),
                    minimumDate: DateTime(1900),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime pickedDate) {
                      tempDate = pickedDate;
                    },
                  ),
                ),
                CupertinoButton(
                  child: const Text("Done"),
                  onPressed: () {
                    setState(() {
                      _birthDate = tempDate ?? DateTime(2000);
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (pickedDate != null) {
        setState(() {
          _birthDate = pickedDate;
        });
      }
    }
  }

  void _onFinish() {
    if (_birthDate != null && _gender != null && _runFrequency != null) {
      _authService.updateUserDoc(
        widget.userId,
        {
          'username': _usernameController.text.trim(),
          'birthDate': _birthDate!.toIso8601String(),
          'gender': _gender,
          'runFrequency': _runFrequency,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
    }
  }

  bool _isPageValid(int index) {
    switch (index) {
      case 0:
        return _usernameController.text.trim().isNotEmpty &&
            _birthDate != null &&
            _gender != null;
      case 1:
        return _runFrequency != null;
      case 2:
        return true; // Location permission button ensures functionality
      case 3:
        return true; // Notification permission button ensures functionality
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          // Step 1: Username, Birthdate, and Gender
          PageViewModel(
            title: "Tell us about you",
            bodyWidget: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: _birthDate == null
                            ? "Select Birth Date"
                            : "Birth Date: ${_birthDate!.toLocal()}".split(' ')[0],
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Gender"),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  value: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Step 2: Run Frequency
          PageViewModel(
            title: "How often do you run?",
            bodyWidget: Column(
              children: [
                RadioListTile(
                  title: const Text("1-2 times a week"),
                  value: "1-2 times a week",
                  groupValue: _runFrequency,
                  onChanged: (value) {
                    setState(() {
                      _runFrequency = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("2-4 times"),
                  value: "2-4 times",
                  groupValue: _runFrequency,
                  onChanged: (value) {
                    setState(() {
                      _runFrequency = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("4-6 times"),
                  value: "4-6 times",
                  groupValue: _runFrequency,
                  onChanged: (value) {
                    setState(() {
                      _runFrequency = value;
                    });
                  },
                ),
                RadioListTile(
                  title: const Text("6+"),
                  value: "6+",
                  groupValue: _runFrequency,
                  onChanged: (value) {
                    setState(() {
                      _runFrequency = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Step 3: Location Permission
          PageViewModel(
            title: "Location Access",
            body:
                "We need location access to track your runs accurately and provide route insights.",
            footer: ElevatedButton(
              onPressed: () async {
                try {
                  await locationPermissions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Location permission granted!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Allow Location Access"),
            ),
          ),
          // Step 4: Notification Permission
          PageViewModel(
            title: "Notifications",
            body:
                "Allow notifications to receive updates, encouragement, and reminders.",
            footer: ElevatedButton(
              onPressed: () async {
                await FirebaseMessaging.instance.requestPermission(
                  alert: true,
                  announcement: false,
                  badge: true,
                  carPlay: false,
                  criticalAlert: false,
                  provisional: false,
                  sound: true,
                );
              },
              child: const Text("Allow Notifications"),
            ),
          ),
        ],
        onDone: _onFinish,
        next: ElevatedButton(
          onPressed: _isPageValid(currentPageIndex) ? () {} : null,
          child: const Text("Next"),
        ),
        done:
            const Text("Finish", style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          activeColor: Colors.blue,
        ),
        onChange: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        showSkipButton: false, // Removed skip functionality
      ),
    );
  }
}
