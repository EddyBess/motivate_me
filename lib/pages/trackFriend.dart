import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motivate_me/audio/recorder.dart';
import 'package:motivate_me/pages/home.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/format.dart';
import 'package:motivate_me/utils/colors.dart';
import 'package:motivate_me/components/running_info_card.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

class TrackFriend extends StatefulWidget {
  final Map<String, dynamic>? trackedUser;

  const TrackFriend({this.trackedUser, super.key});

  @override
  State<TrackFriend> createState() => _TrackFriendState();
}

class _TrackFriendState extends State<TrackFriend> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  late User currentUser;
  MapController mapController = MapController();

  DateTime? startTime;
  Timer? timer;
  LatLng? trackerLocation;
  List<LatLng> trackerRoute = [];
  String trackerRunnedDistance = "0";
  String trackerCurrentSpeed = "0";
  int elapsedSeconds = 0;
  String elapsedTime = "--:--:--";
  bool loader = true;
  bool runComplete = false;
  StreamSubscription? _trackingSubscription;
  double completionBannerOpacity = 1.0;
  void startTimer() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          elapsedSeconds = DateTime.now().difference(startTime!).inSeconds;
          elapsedTime =
              formatElapsedTime(elapsedSeconds); // Update elapsedTime directly
        });
      });
    }
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    currentUser = firebaseAuth.currentUser!;
    _startTrackingTrackedUser();
  }

  @override
  void dispose() {
    // Cancel the timer
    timer?.cancel();
    timer = null;

    // Cancel the Firebase Realtime Database subscription
    _trackingSubscription?.cancel();
    _trackingSubscription = null;

    super.dispose();
  }

  void _startTrackingTrackedUser() {
    _trackingSubscription?.cancel(); // Cancel any existing subscription
    if (!mounted) return;

    if (widget.trackedUser != null) {
      DatabaseReference ref =
          firebaseDatabase.ref("users/${widget.trackedUser!["uid"]}/running");

      // Start listening for real-time updates
      _trackingSubscription = ref.onValue.listen((event) {
        final data = event.snapshot.value as Map?;

        if (startTime == null) {
          setState(() {
            startTime = DateTime.parse(data!["startTime"]);
          });
          startTimer();
        }

        if (data != null) {
          final locationData = data['currentLocation'] as Map?;
          final routeData = data['userTrack'] as List?;

          setState(() {
            if (locationData != null) {
              trackerLocation = LatLng(
                locationData['lat'],
                locationData['long'],
              );
            }

            if (routeData != null) {
              trackerRoute = routeData
                  .map((trackPoint) => LatLng(
                        trackPoint['latitude'],
                        trackPoint['longitude'],
                      ))
                  .toList();
            }
            if(data['runnedDistance'] == ""){
              _trackingSubscription!.cancel();
              timer!.cancel();
              runComplete = true;
              Confetti.launch(
                  context,
                  options: const ConfettiOptions(
                      particleCount: 100, spread: 70, y: 0.6),
                );
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    completionBannerOpacity = 0.0;
                  });
                  
                }
              });
              return;
            }
            trackerRunnedDistance = data['runnedDistance'] ?? "0";
            trackerCurrentSpeed = data['currentSpeed'] ?? "0";
            
            
            
            // Move the map to the new location
            if (trackerLocation != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                mapController.move(trackerLocation!, mapController.camera.zoom);
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: trackerLocation != null
          ? Stack(
              children: [
                // Map Widget
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: trackerLocation!,
                    initialZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: trackerRoute,
                          color: CustomColors().primaryGreen,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: trackerLocation!,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                    widget.trackedUser!["profilePic"],
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -25,
                                child: IntrinsicWidth(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      widget.trackedUser == null
                                          ? currentUser.displayName ?? 'You'
                                          : widget.trackedUser!["username"] ??
                                              'Friend',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RunningInfoCard(
                    distance: double.parse(trackerRunnedDistance),
                    time: elapsedTime,
                    pace: trackerCurrentSpeed,
                    expandable: true,
                    runnerId: !runComplete ? widget.trackedUser!["uid"] : "",
                    scaffContext: context,
                  ),
                ),
                if(runComplete) Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      opacity: completionBannerOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          width: getWidth(context) * 0.9,
                          height: getHeight(context) * 0.2,
                          color: CustomColors().primaryGreen,
                          child: Center(
                            child: Text(
                              "${widget.trackedUser!["username"].toString().toUpperCase()} HAS COMPLETED A RUN!",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

              ],
            )
          : Center(
              child: Column(
                children: [
                  Text(
                    "Fetching ${widget.trackedUser!["username"]} position",
                    style: const TextStyle(color: Colors.white),
                  ),
                  CircularProgressIndicator(
                    color: CustomColors().primaryGreen,
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
