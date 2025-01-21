import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

double log2(num x) {
  return log(x) / log(2);
}

double calculateTotalDistance(List<LatLng> userTrack) {
  if (userTrack.length < 2) return 0.0;

  double totalDistance = 0.0;
  LatLng previousPoint = userTrack.first;

  for (LatLng point in userTrack.skip(1)) {
    totalDistance += Geolocator.distanceBetween(
      previousPoint.latitude,
      previousPoint.longitude,
      point.latitude,
      point.longitude,
    );
    previousPoint = point;
  }

  return totalDistance / 1000;
}

double computeSpeedInKm(List<double> speedValues) {
  if (speedValues.isEmpty) return 0.0;

  double averageSpeed =
      speedValues.reduce((a, b) => a + b) / speedValues.length;
  return averageSpeed * 3.6;
}
String computePaceInMinPerKm(double distance,int elapsedSeconds, bool roundUp) {
  if (distance == 0) return "0:00";


  // Compute average pace
  double averagePace = (elapsedSeconds / 60)/distance;

  int minutes = averagePace.floor();
  int seconds = ((averagePace - minutes) * 60).round();

  if (roundUp) {
    seconds = (seconds / 5).round() * 5;
    if (seconds == 60) {
      minutes += 1;
      seconds = 0;
    }
  }

  return "$minutes:${seconds < 10 ? "0$seconds" : seconds}";
}


