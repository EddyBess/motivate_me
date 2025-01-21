import 'dart:async';

import 'package:flutter/services.dart';
import 'package:motivate_me/services/runHistoryService.dart';
import 'package:motivate_me/services/runnerService.dart';
import 'package:motivate_me/utils/computation.dart';
import 'package:motivate_me/utils/format.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/audio/player.dart';
import 'package:motivate_me/services/rankService.dart';
import 'package:motivate_me/services/statService.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:motivate_me/components/running_info_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class Startrun extends StatefulWidget {
  const Startrun({super.key});

  @override
  State<Startrun> createState() => _StartrunState();
}

class _StartrunState extends State<Startrun> {
  late RunnerService runnerService;
  late StatService statService;
  late RankService rankService;
  late RunHistoryService runHistoryService;
  late DateTime startTime;

  final FirebaseAuth auth = FirebaseAuth.instance;

  String currentPace = ""; // Improved variable name
  Timer? timer;

  bool running = false;
  bool paused = false;
  bool displayTimer = true;

  LatLng currentLocation = const LatLng(0, 0);
  List<LatLng> userTrack = [];
  int elapsedSeconds = 0;
  double distance = 0;
  CountDownController countDownController = CountDownController();

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  // Function to initialize background geolocation
  Future<void> _initializeGeolocation() async {
    try {
      await bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10,
        disableElasticity: true,
        stopOnTerminate: true,
        startOnBoot: false,
        activityType: bg.Config.ACTIVITY_TYPE_FITNESS,
        notification: bg.Notification(
          title: "Running in background",
          text: "Motivate Me is tracking your location.",
        ),
      ));
      final status = await bg.BackgroundGeolocation.requestPermission();
      if (status != bg.Config.AUTHORIZATION_STATUS_ALWAYS) {
        if (kDebugMode) {
          print("Permission denied. Request 'Always' location permission.");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Geolocation initialization error: $error");
      }
    }
  }

  // Function to start geolocation tracking
  Future<void> _startGeolocation() async {
    try {
      await bg.BackgroundGeolocation.start();
      if (kDebugMode) print("Geolocation tracking started");
    } catch (error) {
      if (kDebugMode) {
        print("Geolocation start error: $error");
      }
    }
  }

  // Function to stop geolocation tracking
  Future<void> _stopGeolocation() async {
    try {
      await bg.BackgroundGeolocation.stop();
      if (kDebugMode) print("Geolocation tracking stopped");
    } catch (error) {
      if (kDebugMode) {
        print("Geolocation stop error: $error");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    runnerService = RunnerService(auth.currentUser!);
    statService = StatService(auth.currentUser!);
    rankService = RankService(auth.currentUser!);
    runHistoryService = RunHistoryService(auth.currentUser!);
    startTime = DateTime.now();

    // Initialize geolocation
    _initializeGeolocation();

    // Configure location listener
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (running && !paused) {
        setState(() {
          currentLocation =
              LatLng(location.coords.latitude, location.coords.longitude);
          userTrack.add(currentLocation);
          distance = calculateTotalDistance(userTrack);
          currentPace = computePaceInMinPerKm(distance, elapsedSeconds, true);
        });
        runnerService.updateActivityInformation(
          currentLocation.latitude,
          currentLocation.longitude,
          currentPace,
          distance.toStringAsFixed(2),
          userTrack,
          startTime.toIso8601String(),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _stopGeolocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = getWidth(context);
    double height = getHeight(context);
    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            VoiceMessagePlayer(runnerId: auth.currentUser!.uid),
            displayTimer
                ? Column(
                    children: [
                      const Text(
                        "READY ?",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                      CircularCountDownTimer(
                        width: width * 0.3,
                        height: height * 0.3,
                        autoStart: false,
                        duration: 3,
                        fillColor: CustomColors().tertiaryGrey,
                        ringColor: CustomColors().primaryGreen,
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 33),
                        isReverse: true,
                        strokeCap: StrokeCap.round,
                        controller: countDownController,
                        onComplete: () {
                          HapticFeedback.vibrate();
                          runnerService.setRunnerStatus(true);
                          startTime = DateTime.now();
                          startTimer();
                          _startGeolocation();
                          setState(() {
                            running = true;
                            displayTimer = false;
                          });
                        },
                      )
                    ],
                  )
                : SizedBox(
                    width: width * 0.9,
                    child: RunningInfoCard(
                        scaffContext: context,
                        distance: distance,
                        time: formatElapsedTime(elapsedSeconds),
                        pace: currentPace),
                  ),
            Column(
              children: [
                SizedBox(
                  width: width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!running && !paused) {
                        countDownController.start();
                      } else if (running && !paused) {
                        // Pause the run
                        stopTimer();
                        setState(() {
                          paused = true;
                        });
                      } else if (paused) {
                          startTimer();
                          setState(() {
                            paused = false;
                          });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: !running
                            ? CustomColors().primaryGreen
                            : paused
                                ? CustomColors().primaryYellow
                                : CustomColors().primaryRed,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)))),
                    child: Text(
                      !running
                          ? "START ACTIVITY"
                          : paused
                              ? "RESUME ACTIVITY"
                              : "PAUSE ACTIVITY",
                      style: TextStyle(
                          color:
                              !running ? CustomColors().primaryGrey : Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                if (paused)
              SizedBox(
                width: width * 0.6,
                child: ElevatedButton(
                  onPressed: () {
                    // Stop the run
                    runnerService.setRunnerStatus(false);
                    runnerService.resetRunnerRealTimeDB(
                        currentLocation.latitude, currentLocation.longitude);
                    _stopGeolocation();

                    double totalDistance = calculateTotalDistance(userTrack);
                    String avgSpeed = computePaceInMinPerKm(
                        totalDistance, elapsedSeconds, false);

                    statService.updateUserTotalDistance(totalDistance);
                    rankService.updateUserRank(totalDistance, avgSpeed);

                    Map<String, dynamic> run = {
                      "distance": totalDistance,
                      "rankProgression":
                          rankService.computePoints(totalDistance, avgSpeed),
                      "userTrack": userTrack
                          .map((latLng) => {
                                'latitude': latLng.latitude,
                                'longitude': latLng.longitude,
                              })
                          .toList(),
                      "speedAvg": avgSpeed,
                      "date": startTime.toIso8601String(),
                      "length": formatElapsedTime(elapsedSeconds)
                    };
                    runHistoryService.addRun(run);

                    setState(() {
                      elapsedSeconds = 0;
                      currentLocation = const LatLng(0, 0);
                      userTrack = [];
                      running = false;
                      paused = false;
                      displayTimer = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors().primaryRed,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  child: const Text(
                    "STOP ACTIVITY",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
