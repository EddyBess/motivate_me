import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:motivate_me/pages/trackFriend.dart';

class MiniMap extends StatefulWidget {
  final double widthPercentage;
  final Map<String, dynamic>? trackedUser;

  const MiniMap({required this.widthPercentage, this.trackedUser, super.key});

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

  late User currentUser;
  late LatLng currentUserPosition;

  MapController mapController = MapController();
  LatLng? trackerLocation;
  List<LatLng> trackerRoute = [];
  String trackerTraveledDistance = "";
  String trackerCurrentSpeed = "";

  bool loader = true;
  StreamSubscription? _trackingSubscription;

  @override
  void initState() {
    super.initState();
    currentUser = firebaseAuth.currentUser!;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart tracking only if trackedUser has changed
    if (oldWidget.trackedUser != widget.trackedUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTrackingTrackedUser();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        currentUserPosition = LatLng(position.latitude, position.longitude);
        loader = false;
      });
    }
  }

  void _startTrackingTrackedUser() {
    _trackingSubscription?.cancel();
    if (mounted) {
      setState(() {
        trackerLocation = null;
        trackerRoute.clear();
        mapController.move(currentUserPosition, 18);
      });

      if (widget.trackedUser != null) {
        DatabaseReference ref =
            firebaseDatabase.ref("users/${widget.trackedUser!["uid"]}/running");

        _trackingSubscription = ref.onValue.listen((event) {
          final data = event.snapshot.value as Map?;
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

              trackerTraveledDistance = data['traveledDistance'] ?? "0";
              trackerCurrentSpeed = data['currentSpeed'] ?? "0";
              WidgetsBinding.instance.addPostFrameCallback((_) {
                    mapController.move(trackerLocation ?? currentUserPosition, mapController.camera.zoom);
              });
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: width * widget.widthPercentage,
            height: height * 0.3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.3),
                //     spreadRadius: 2,
                //     blurRadius: 8,
                //     offset: const Offset(2, 2),
                //   ),
                // ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // FlutterMap widget
                    loader == false
                        ? FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter:
                                  trackerLocation ?? currentUserPosition,
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
                                    color: Colors.black,
                                    strokeWidth: 4,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point:
                                        trackerLocation ?? currentUserPosition,
                                    width:
                                        width, // Set the overall width of the marker
                                    height: height *
                                        0.06, // Set height to accommodate both the text and image
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Profile picture
                                        Positioned(
                                          bottom: 0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.network(
                                              widget.trackedUser == null
                                                  ? currentUser.photoURL
                                                  : widget.trackedUser![
                                                      "profilePic"],
                                              fit: BoxFit.cover,
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                        // Username text positioned above the picture
                                        Positioned(
                                          top: 0,
                                          child: IntrinsicWidth(
                                            child: Container(
                                              color: Colors.white,
                                              child: Text(
                                                widget.trackedUser == null
                                                    ? "You are here "
                                                    : widget.trackedUser![
                                                            "username"] ??
                                                        'Friend',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow
                                                    .ellipsis, // Truncate text if too long
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
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                    // Icon button overlay
                    widget.trackedUser != null
                        ? Positioned(
                            top: 10,
                            right: 10,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              child: Container(
                                color: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return TrackFriend(
                                        key: UniqueKey(),
                                        trackedUser: widget.trackedUser,
                                      );
                                    }));
                                  },
                                  icon: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.black,
                                  ),
                                  iconSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
