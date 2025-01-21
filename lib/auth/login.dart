import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivate_me/navigation.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motivate_me/pages/home.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://images.pexels.com/photos/5319494/pexels-photo-5319494.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Top triangle overlay
          Positioned.fill(
            child: CustomPaint(
              painter: TopTrianglePainter(),
            ),
          ),
          // Middle quadrilateral overlay
          Positioned.fill(
            child: CustomPaint(
              painter: MiddleQuadrilateralPainter(),
            ),
          ),
          // Bottom triangle overlay
          Positioned.fill(
            child: CustomPaint(
              painter: BottomTrianglePainter(),
            ),
          ),
          // Centered Google Sign-In button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("PACE UP",style: TextStyle(fontSize: 70,fontWeight: FontWeight.bold,fontFamily: GoogleFonts.barlowSemiCondensed().fontFamily,)),
                SizedBox(height: getHeight(context)*0.1,),
                SizedBox(
                  width: getWidth(context) * 0.6,
                  height: 40,
                  child: SignInButton(
                    Buttons.google,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () async {
                      try {
                        User? user = await _signInWithGoogle();
                        if (user != null) {
                          var userDoc = await firestore
                              .collection('users')
                              .doc(user.uid)
                              .get();
                          await messaging.getAPNSToken();
                          String? fcmToken = await messaging.getToken();
                
                          if (!userDoc.exists) {
                            firestore.collection('users').doc(user.uid).set({
                              'username': user.displayName,
                              'friendsRequest': [],
                              'friends': [],
                              'profilePic': user.photoURL,
                              'running': false,
                              'fcm_token': fcmToken,
                              'uid': user.uid
                            });
                          }
                          var statDoc = await firestore
                              .collection('stats')
                              .where('uid', isEqualTo: user.uid)
                              .get();
                          if (statDoc.docs.isEmpty) {
                            firestore.collection('stats').doc().set({
                              'totalDistance': 0,
                              'totalTime': 0,
                              'uid': user.uid
                            });
                          }
                          // Successful sign-in
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Logged in as : ${user.displayName}'),
                          ));
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: ((context) {
                            return Navigation();
                          })));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                            content: Text('Sign in failed'),
                          ));
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    text: 'Sign in with Google',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Top Triangle Painter
class TopTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CustomColors().tertiaryGrey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, 0); // Top-left corner
    path.lineTo(size.width, 0); // Top-right corner
    path.lineTo(
        size.width, size.height * 0.25); // Top-right corner of quadrilateral
    path.lineTo(0, size.height * 0.7); // Bottom-left triangle edge
    path.close(); // Close the triangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// Middle Quadrilateral Painter
class MiddleQuadrilateralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CustomColors().secondaryGrey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, size.height * 0.7); // Top-left corner of quadrilateral
    path.lineTo(
        size.width, size.height * 0.25); // Top-right corner of quadrilateral
    path.lineTo(
        size.width, size.height * 0.88); // Bottom-right corner of quadrilateral
    path.lineTo(
        size.width * 0.7, size.height); // Bottom-right corner of quadrilateral
    path.lineTo(0, size.height); // Bottom-left corner of quadrilateral
    path.close(); // Close the quadrilateral

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// Bottom Triangle Painter
class BottomTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CustomColors().primaryGreen.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(size.width, size.height); // Bottom-right corner
    path.lineTo(size.width * 0.7, size.height); // Bottom-left corner
    path.lineTo(size.width, size.height * 0.88); // Upper-right triangle edge
    path.close(); // Close the triangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
