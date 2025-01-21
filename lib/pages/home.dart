import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motivate_me/components/friends_selector.dart';
import 'package:motivate_me/components/mini_map.dart';
import 'package:motivate_me/pages/completedRun.dart';
import 'package:motivate_me/services/friendService.dart';
import 'package:motivate_me/services/rankService.dart';
import 'package:motivate_me/services/runHistoryService.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/permissions.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/components/tiled_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motivate_me/utils/constants.dart';
import 'package:motivate_me/components/changeLogModal.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motivate_me/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FriendService friendService =
      FriendService(FirebaseAuth.instance.currentUser!);
  final RankService rankService =
      RankService(FirebaseAuth.instance.currentUser!);
  final RunHistoryService runHistoryService =
      RunHistoryService(FirebaseAuth.instance.currentUser!);

  List<Map<String, dynamic>> userFriends = [];
  Map<String, dynamic>? trackedUser; // Track the UID of the selected friend

  bool showChangelogModal = false;

  Future<void> fetchRunningFriends() async {
    friendService.getRunningFriends().listen((runningFriends) {
      setState(() {
        userFriends = runningFriends;
      });
      if (userFriends.isEmpty) {
        onFriendSelected(null);
      }
    });
  }

  // Method to handle friend selection
  void onFriendSelected(Map<String, dynamic>? friendSelected) {
    setState(() {
      trackedUser = friendSelected; // Set tracked user UID
    });
  }

  Future<void> checkIfChangelog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final double? appVersion = prefs.getDouble('appVersion');
    if (appVersion == null || appVersion < APP_VERSION) {
      setState(() {
        prefs.setDouble('appVersion', APP_VERSION);
        showChangelogModal = true;
      });
    }
  }

  // Method to show the ChangelogModal dialog
  void displayChangelogDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeLogModal(
          version: APP_VERSION.toString(),
          majorUpdates: const [
            'Updating UI/UX',
            'Improved battery management'
          ],
          bugFixes: const [
            'Background tracking'
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    locationPermissions();
    fetchRunningFriends();
    checkIfChangelog();
  }

  @override
  Widget build(BuildContext context) {
    double width = getWidth(context);
    double height = getHeight(context);
    if (showChangelogModal) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => displayChangelogDialog());
    }

    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      body: Padding(
        padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),
              const Row(
                children: [
                  Text(
                    "Welcome !",
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  MiniMap(
                    widthPercentage: userFriends.isNotEmpty ? 0.7 : 0.9,
                    trackedUser: trackedUser, // Pass the trackedUserUid here
                  ),
                  SizedBox(width: userFriends.isNotEmpty ? width * 0.05 : 0),
                  userFriends.isNotEmpty
                      ? FriendsSelector(
                          friends: userFriends,
                          onFriendSelected: onFriendSelected,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              // StreamBuilder<int>(
              //   stream: rankService.getUserRank(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.active &&
              //         snapshot.hasData) {
              //       int points = snapshot.data!;
              //       Map<String, dynamic> ranks =
              //           rankService.getRankAndNextRank(points);

              //       return Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           Text(ranks["currentRank"]!,style: const TextStyle(color: Colors.white),),
              //           SizedBox(
              //             width: width * 0.6,
              //             child: TweenAnimationBuilder<double>(
              //               duration: const Duration(milliseconds: 550),
              //               curve: Curves.easeInOut,
              //               tween: Tween<double>(
              //                   begin: 0,
              //                   end: (ranks["nextRankPoints"] -
              //                               ranks["currentRankPoints"]) ==
              //                           0
              //                       ? 1.0 // Handle the case where current and next rank points are equal
              //                       : (points - ranks["currentRankPoints"]) /
              //                           (ranks["nextRankPoints"] -
              //                               ranks["currentRankPoints"])),
              //               builder: (context, value, _) =>
              //                   LinearProgressIndicator(value: value,
              //                   backgroundColor: CustomColors().tertiaryGrey,
              //                   color: CustomColors().primaryGreen,
              //                   ),
              //             ),
              //           ),
              //           Text(ranks["nextRank"]!,style: const TextStyle(color: Colors.white)),
              //         ],
              //       );
              //     }
              //     return const SizedBox.shrink();
              //   },
              // ),
              Text("Rank feature coming soon !",style: TextStyle(color: CustomColors().tertiaryGrey,fontStyle: FontStyle.italic),),
              SizedBox(height: height * 0.05),
              const Text("Recent Runs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: runHistoryService.getRunHistoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(color: CustomColors().primaryGreen,);
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No recent runs available."));
                  }

                  // Display each run in a tile
                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var runData = snapshot.data!.docs[index].data();
                        return Column(
                          children: [
                            RunTile(runData: runData),
                            Divider(height: 2,color: CustomColors().tertiaryGrey,),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RunTile extends StatelessWidget {
  final Map<String, dynamic> runData;

  const RunTile({required this.runData});

  @override
  Widget build(BuildContext context) {
    double distance = runData['distance'];
    String speedAvg = runData['speedAvg'].toString();
    String rankProgression = runData['rankProgression'].toString();
    List userTrack = runData['userTrack'];
    DateTime date = DateTime.parse(runData['date']);

    final DateFormat format = DateFormat("MMMM dd - HH:mm");

    double width = getWidth(context);
    double height = getHeight(context);

    return userTrack.length > 1
        ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CompletedRunPage(runData: runData));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: width * 0.25,
                      height: width * 0.25,
                      child: TiledMap(
                        initialPosition: LatLng(
                          userTrack.first['latitude'],
                          userTrack.first['longitude'],
                        ),
                        size: width * 0.25,
                        userTrack: userTrack
                            .map((point) =>
                                LatLng(point['latitude'], point['longitude']))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Run Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          format.format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CustomColors().tertiaryGrey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Distance
                        Text(
                          "${distance.toStringAsFixed(2)} km",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$speedAvg mn/km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                )),
                            Text(
                              "+$rankProgression pts",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CustomColors().primaryGreen,
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: CustomColors().tertiaryGrey),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
