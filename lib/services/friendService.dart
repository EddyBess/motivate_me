import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  /* Service to retrieve all information related to the current user's friends */
  final User currentUser;
  FriendService(this.currentUser);

  // Get the current user's document snapshot as a stream
  Stream<DocumentSnapshot> getUserDocSnapshot() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots();
  }

  // Retrieve the list of friends with batch processing for efficiency
  Future<List<Map<String, dynamic>>> getUsersFriends() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = userDoc.data() as Map<String, dynamic>;
    List<dynamic> friendsIds = data["friends"] ?? [];

    // Fetch friends' data in a single batch using `whereIn`
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsIds)
        .get();

    return friendsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFriendsRequests() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = userDoc.data() as Map<String, dynamic>;
    List<dynamic> friendsIds = data["friendsRequest"] ?? [];

    // Fetch friends' data in a single batch using `whereIn`
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsIds)
        .get();

    return friendsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Retrieve the list of friends with batch processing for efficiency
  Stream<List<Map<String, dynamic>>> getUsersFriendsStream() {
    // Listen to changes in the current user's document
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      final data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> friendsIds = data?["friends"] ?? [];

      if (friendsIds.isEmpty) {
        return [];
      }

      // Fetch friends' data in a single batch using `whereIn`
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsIds)
          .get();

      return friendsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getFriendsRequestsStream() {
    // Listen to changes in the current user's document
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      final data = userDoc.data() as Map<String, dynamic>?;
      List<dynamic> friendsRequestIds = data?["friendsRequest"] ?? [];

      if (friendsRequestIds.isEmpty) {
        return [];
      }

      // Fetch friends request data in a single batch using `whereIn`
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsRequestIds)
          .get();

      return requestsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Stream to get only friends who are currently running
  Stream<List<Map<String, dynamic>>> getRunningFriends() async* {
    // Get the friends' IDs asynchronously
    List<String> friendsIds = await getFriendsIds();

    // Listen to real-time updates for friends who are currently running
    if (friendsIds.isNotEmpty) {
      yield* FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsIds)
          .where("running", isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    }
  }

  // Helper method to get the current user's friends' IDs as a List
  Future<List<String>> getFriendsIds() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final data = userDoc.data() as Map<String, dynamic>;
    return List<String>.from(data["friends"] ?? []);
  }

  void acceptFriendRequest(friendUid) {
    FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      "friends": FieldValue.arrayUnion([friendUid]),
      "friendsRequest": FieldValue.arrayRemove([friendUid])
    });
    FirebaseFirestore.instance.collection('users').doc(friendUid).update({
      "friends": FieldValue.arrayUnion([currentUser.uid]),
    });
  }

  void declineFriendRequest(friendUid) {
    FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
      "friendsRequest": FieldValue.arrayRemove([friendUid])
    });
  }
}
