import 'package:flutter/material.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivate_me/audio/recorder.dart';

class RunningInfoCard extends StatefulWidget {
  final double distance;
  final String time;
  final String pace;
  final BuildContext scaffContext;
  final bool? expandable;
  final String? runnerId;

  const RunningInfoCard({
    required this.distance,
    required this.time,
    required this.pace,
    required this.scaffContext,
    this.expandable = false,
    this.runnerId = "",
    super.key,
  });

  @override
  State<RunningInfoCard> createState() => _RunningInfoCardState();
}

class _RunningInfoCardState extends State<RunningInfoCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double width = getWidth(context);
    double height = getHeight(context);

    return GestureDetector(
      onTap: () {
        if (widget.expandable == true) {
          setState(() {
            isExpanded = !isExpanded;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: widget.expandable == true
            ? (isExpanded ? height * 0.25 : height * 0.15)
            : height * 0.25,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 13),
        decoration: BoxDecoration(
            color: CustomColors()
                .primaryGrey
                .withOpacity(widget.expandable == true ? 0.9 : 1),
            borderRadius:
                BorderRadius.circular(widget.expandable == true ? 0 : 15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Draggable indicator
                if (widget.expandable == true)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: CustomColors().tertiaryGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                // Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Duration",
                      style: TextStyle(
                          color: CustomColors().tertiaryGrey,
                          fontWeight: FontWeight.w100),
                    ),
                   Text(
                   widget.runnerId != "" ? "Motivate":"",
                  style: TextStyle(
                      color: CustomColors().tertiaryGrey,
                      fontWeight: FontWeight.w100),
                ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: widget.time,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 48,
                            letterSpacing: 2.0,
                            fontFamily:
                                GoogleFonts.barlowSemiCondensed().fontFamily),
                        children: [
                          TextSpan(
                            text: ' min',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 24,
                                fontFamily: GoogleFonts.inter().fontFamily),
                          ),
                        ],
                      ),
                    ),
                    widget.runnerId != ""
                        ? VoiceMessageRecorder(runnerId: widget.runnerId!,scaffContext: widget.scaffContext,)
                        : const SizedBox.shrink()
                  ],
                ),
              ],
            ),
            if (isExpanded || widget.expandable == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("Distance",
                          style: TextStyle(
                              color: CustomColors().tertiaryGrey,
                              fontWeight: FontWeight.w100)),
                      Text(widget.distance.toStringAsFixed(2),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontFamily:
                                  GoogleFonts.barlowSemiCondensed().fontFamily,
                              fontSize: 24)),
                      const Text("km",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Text("Pace",
                          style: TextStyle(
                              color: CustomColors().tertiaryGrey,
                              fontWeight: FontWeight.w100)),
                      Text(widget.pace,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              fontFamily:
                                  GoogleFonts.barlowSemiCondensed().fontFamily,
                              fontSize: 24)),
                      const Text("min/km",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600))
                    ],
                  ),
                  Column(
                    children: [
                      Text("Calories",
                          style: TextStyle(
                              color: CustomColors().tertiaryGrey,
                              fontWeight: FontWeight.w100)),
                      Text("---",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  GoogleFonts.barlowSemiCondensed().fontFamily,
                              fontSize: 24)),
                      const Text("kcal",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600))
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
