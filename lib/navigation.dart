import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motivate_me/auth/login.dart';
import 'package:motivate_me/pages/home.dart';
import 'package:motivate_me/pages/profile.dart';
import 'package:motivate_me/pages/startRun.dart';
import 'package:motivate_me/pages/friends.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:motivate_me/ui/colors.dart';
class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomePage(key: UniqueKey(),),
      Startrun(),
      FriendsPage(),
      ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: CustomColors().primaryGreen,
        inactiveColorPrimary: CustomColors().tertiaryGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.play_arrow),
        title: ("Run"),
        activeColorPrimary: CustomColors().primaryGreen,
        inactiveColorPrimary: CustomColors().tertiaryGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.group),
        title: ("Friends"),
        activeColorPrimary: CustomColors().primaryGreen,
        inactiveColorPrimary: CustomColors().tertiaryGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),  // Changed icon for Profile tab
        title: ("Profile"),
        activeColorPrimary: CustomColors().primaryGreen,
        inactiveColorPrimary: CustomColors().tertiaryGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return FirebaseAuth.instance.currentUser != null ? PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      backgroundColor: CustomColors().primaryGrey,
      padding: const EdgeInsets.symmetric(vertical: 8),
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: false,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style6,
    ):SignInPage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
