import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:motivate_me/components/tiled_map.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/ui/colors.dart';
class CompletedRunPage extends StatefulWidget {
  final Map<String, dynamic> runData;

  const CompletedRunPage({
    Key? key,
    required this.runData,
  }) : super(key: key);

  @override
  State<CompletedRunPage> createState() => CompletedRunPageState();
}

class CompletedRunPageState extends State<CompletedRunPage> {
  DateFormat format = DateFormat("MMMM dd, yyyy");

  @override
  Widget build(BuildContext context) {
    double width = getWidth(context);
    double height = getHeight(context);

    List userTrack = widget.runData["userTrack"];
    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      body: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              height: height * 0.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: TiledMap(
                  size: width * 0.9,
                  userTrack: userTrack
                      .map((point) => LatLng(point['latitude'], point['longitude']))
                      .toList(),
                  initialPosition: LatLng(
                    userTrack.first['latitude'],
                    userTrack.first['longitude'],
                  ),
                ),
              ),
            ),
             SizedBox(
              height: height*0.05,
            ),
            Text(
              format.format(DateTime.parse(widget.runData["date"])),
              style: const TextStyle(fontSize: 18,color: Colors.white),
            ),
            SizedBox(
              height: height*0.05,
            ),
            SizedBox(
              height: height * 0.25,
              width: width * 0.9,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                children: [
                  buildStatColumn("Time", "${widget.runData["length"]}"),
                  buildStatColumn("Distance", "${widget.runData["distance"].toStringAsFixed(2)} km"),
                  buildStatColumn("Speed Average", "${widget.runData["speedAvg"]} min/km"),
                  buildStatColumn("Rank Progression", "+${widget.runData["rankProgression"]}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatColumn(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style:  TextStyle(fontSize: 12, color: CustomColors().tertiaryGrey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
        ),
      ],
    );
  }
}
