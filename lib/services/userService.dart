import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Authservice {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<User?> signInWithGoogle() async {
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
      return null;
    }
  }

  Future<User?> emailRegistration(String emailAddress, String password) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> emailLogin(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> createUserDocs(User user) async {
    var userDoc = await firestore.collection('users').doc(user.uid).get();
    //await messaging.getAPNSToken();
    //String? fcmToken = await messaging.getToken();

    if (!userDoc.exists) {
      firestore.collection('users').doc(user.uid).set({
        'username': user.displayName,
        'friendsRequest': [],
        'friends': [],
        'profilePic': user.photoURL,
        'running': false,
        'fcm_token': "fcmToken",
        'uid': user.uid
      });
    }
    var statDoc = await firestore
        .collection('stats')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (statDoc.docs.isEmpty) {
      firestore
          .collection('stats')
          .doc()
          .set({'totalDistance': 0, 'totalTime': 0, 'uid': user.uid});
    }
  }

  Future<void> updateUserDoc(String userId, Map<String, dynamic> data) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.set(
          data, SetOptions(merge: true)); // Merge with existing fields
      print("User document updated successfully");
    } catch (e) {
      print("Error updating user document: $e");
    }
  }
}
