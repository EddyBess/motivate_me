import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankService {
  final User currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  RankService(this.currentUser);

  /// Fetches and returns a sorted list of friends based on rank.
  Future<List<Map<String, dynamic>>> getSortedFriendsByRank() async {
    
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = userDoc.data() as Map<String, dynamic>;
    List<String> friendsIds = data["friends"] ?? [];

    // Fetch friends' data and their ranks
    final friendsData = await firestore
        .collection('users')
        .where('uid', whereIn: friendsIds)
        .orderBy('rank', descending: true)
        .get();

    return friendsData.docs.map((doc) => doc.data()).toList();
  }

  /// Fetches and returns a sorted list of all users based on rank.
  Future<List<Map<String, dynamic>>> getSortedUsersByRank() async {
    final usersSnapshot = await firestore
        .collection('users')
        .orderBy('rank', descending: true)
        .get();

    return usersSnapshot.docs.map((doc) => doc.data() ).toList();
  }
}
