import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';

class RunnerService {
  /* Service used to perform all operation related to a runner */

  final User currentUser;
  final FirebaseDatabase db = FirebaseDatabase.instance;

  RunnerService(this.currentUser);

  Future<void> setRunnerStatus(bool status) async {
    /* This will set the user status to running true or false */

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({"running": status});
  }

  Future<void> updateActivityInformation(
      double lat,
      double long,
      String currentSpeed,
      String runnedDistance,
      List<LatLng> userTrack,
      String startTime) async {
    
    
    /* This will update the runner location,pace,distance... */
    
    await db.ref("users/${currentUser.uid}/running").set({
      'currentLocation': {'lat': lat, 'long': long},
      'currentSpeed': currentSpeed,
      'runnedDistance': runnedDistance,
      'userTrack': userTrack
          .map((latLng) => {
                'latitude': latLng.latitude,
                'longitude': latLng.longitude,
              })
          .toList(),
      'startTime': startTime
    });
  
  }

  Future<void> resetRunnerRealTimeDB(double lat, double long) async {
    /* This will reset the runner realtime db to the default values when stopping a run */

    await db.ref("users/${currentUser.uid}/running").set({
      'currentLocation': {'lat': lat, 'long': long},
      'currentSpeed': "",
      'runnedDistance': "",
      'userTrack': List.empty(),
      'startTime': ""
    });
  }



}
