import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:motivate_me/ui/colors.dart';
import 'dart:math';
import 'package:motivate_me/utils/colors.dart';
class TiledMap extends StatelessWidget {
  final List<LatLng> userTrack;
  final LatLng initialPosition;
  final double size;
  final String? username;
  final String? profilePicUrl;
  final void Function()? onFullscreenTap;

  const TiledMap({
    Key? key,
    required this.size,
    required this.userTrack,
    required this.initialPosition,
    this.username,
    this.profilePicUrl,
    this.onFullscreenTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    LatLng computeCentroid(List<LatLng> points) {
      double latitude = 0;
      double longitude = 0;
      int n = points.length;

      for (LatLng point in points) {
        latitude += point.latitude;
        longitude += point.longitude;
      }

      return LatLng(latitude / n, longitude / n);
    }

   
    double log2(num x) => log(x) / log(2);

    double calculateZoomLevel(List<LatLng> userTrack, double mapWidth, double mapHeight) {
      // Step 1: Determine the bounding box
      double minLat = userTrack.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat = userTrack.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
      double minLng = userTrack.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng = userTrack.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

      // Step 2: Calculate differences
      double latDiff = maxLat - minLat;
      double lngDiff = maxLng - minLng;

      // Step 3: Define tile size and minimum difference threshold
      const tileSize = 1.2;
      const minDiff = 0.0001; // Smallest allowable difference to avoid extremes

      // Ensure the differences aren't too small to avoid negative/invalid zooms
      latDiff = latDiff < minDiff ? minDiff : latDiff;
      lngDiff = lngDiff < minDiff ? minDiff : lngDiff;
      
      // Step 4: Calculate zoom levels for width and height
      double zoomX = log2((mapWidth / tileSize) / lngDiff);
      double zoomY = log2((mapHeight / tileSize) / latDiff);
      
      // Step 5: Use the minimum zoom level to fit the entire track on the map
      double optimalZoom = min(zoomX, zoomY);

      return optimalZoom;
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: computeCentroid(userTrack),
            initialZoom: calculateZoomLevel(userTrack,size,size),
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
                  points: userTrack,
                  color: CustomColors().primaryGreen,
                  strokeWidth: 3,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                    width: 10,
                    height: 10,
                    point: initialPosition,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Container(
                        color: Colors.white,
                      ),
                    )),
                Marker(
                  width: 10, // Adjust the size of the marker
                  height: 10,
                  point: userTrack.last,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(30), // Make it rounded
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: CustomPaint(
                        painter: CheckeredFlagPainter(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (onFullscreenTap != null)
          Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.black),
                onPressed: onFullscreenTap,
              ),
            ),
          ),
      ],
    );
  }
}

class CheckeredFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBlack = Paint()..color = Colors.black;
    Paint paintWhite = Paint()..color = Colors.white;

    double squareSize = size.width / 4; // Define the size of each square

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        // Alternate between black and white squares
        Paint paint = (row + col) % 2 == 0 ? paintBlack : paintWhite;

        // Draw each square
        canvas.drawRect(
          Rect.fromLTWH(
              col * squareSize, row * squareSize, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
