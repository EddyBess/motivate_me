import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:motivate_me/navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Navigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: false,
      infiniteAutoScroll: false,
      pages: [
        PageViewModel(
          title: "Welcome to PaceUp",
          bodyWidget: const Column(
            children: [
              Text("Your ultimate running companion."),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.personRunning,
                    size: 30,
                  ),
                  Text("Track Your Runs")
                ],
              ),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.chartLine,
                    size: 30,
                  ),
                  Text("Earn Rewards for Your Pace")
                ],
              ),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.headphones,
                    size: 30,
                  ),
                  Text("Get Motivated With Voice Messages")
                ],
              )
            ],
          ),
          image: SizedBox.shrink(),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Sign Up",
          bodyWidget: Column(
            children: [
              Text("Choose how you want to join PaceUp."),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to signup screen (Email or Google)
                },
                icon: Icon(Icons.email),
                label: Text("Sign Up with Email"),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to signup screen (Google)
                },
                icon: Icon(FontAwesomeIcons.google),
                label: Text("Sign Up with Google"),
              ),
            ],
          ),
          image: SizedBox.shrink(),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Fill Your Details",
          bodyWidget: Column(
            children: [
              Text(
                  "Provide some basic details to personalize your experience."),
              TextField(
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Gender (optional)"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Age"),
              ),
            ],
          ),
          image: SizedBox.shrink(),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Set Your Goal",
          bodyWidget: Column(
            children: [
              Text("How often do you plan to run each week?"),
              DropdownButtonFormField<String>(
                items:
                    ['1-2 times', '3-4 times', '5+ times'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
                decoration: InputDecoration(labelText: "Select Your Goal"),
              ),
              Text("What is your running experience?"),
              DropdownButtonFormField<String>(
                items: ['Beginner', 'Intermediate', 'Advanced']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
                decoration: InputDecoration(labelText: "Running Experience"),
              ),
            ],
          ),
          image: SizedBox.shrink(),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Personal Best Records (Optional)",
          bodyWidget: Column(
            children: [
              Text("Provide your personal best for common distances."),
              TextField(
                decoration: InputDecoration(labelText: "5K Time"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "10K Time"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Half Marathon Time"),
              ),
              TextField(
                decoration: InputDecoration(labelText: "Marathon Time"),
              ),
            ],
          ),
          image: SizedBox.shrink(),
          footer: ElevatedButton(
            onPressed: () => _onIntroEnd(context),
            child: const Text("Done"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
