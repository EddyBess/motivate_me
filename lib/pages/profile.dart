import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/size.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      body: SizedBox(
        width: getWidth(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Work in progress...",style: TextStyle(color: Colors.white),),
            SizedBox(
              width: getWidth(context)*0.5,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors().primaryRed
                ),
                onPressed: (){
                FirebaseAuth.instance.signOut();
              }, child: Text("Sign Out",style: TextStyle(color: Colors.black),)),
            ),
          ],
        ),
      ),
    );
  }
}