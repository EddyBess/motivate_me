import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motivate_me/utils/format.dart';

class RankService {
  /* Service to manage user rank related operations */
  final User currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final DocumentReference userDoc;

  RankService(this.currentUser) {
    // Set the user document reference when the service is initialized
    userDoc = firestore.collection('users').doc(currentUser.uid);
  }

  static const Map<int, String> ranks = {
    0: "Snail", // Rank 0
    250: "Turtle", // Rank 250
    500: "Penguin", // Rank 500
    1000: "Elephant", // Rank 1000
    1500: "Horse", // Rank 1500
    2000: "Greyhound", // Rank 2000
    3000: "Cheetah", // Rank 3000
    4000: "Falcon", // Rank 4000
  };

  // To get the rank name by points
  Map<String, dynamic> getRankAndNextRank(int points) {
    int currentRank = 0;
    int nextRank = 0;

    for (int rank in ranks.keys) {
      if (points >= rank) {
        currentRank = rank;
      } else {
        nextRank = rank;
        break;
      }
    }

    // Handle case when the user is already at the highest rank
    if (nextRank == 0 && currentRank != 0) {
      nextRank = currentRank;
    }

    return {
      'currentRank': ranks[currentRank] ?? "Unknown",
      'nextRank': ranks[nextRank] ?? "No Next Rank",
      'currentRankPoints': currentRank,
      'nextRankPoints': nextRank,
    };
  }

  int computePoints(double distance, String avgSpeed) {
    // 10 points earned per km
    int kmPoints = (distance * 10).toInt();

    // 5 points bonus every 5km
    int bonusPoints = ((distance % 5) * 5).toInt();

    int parsedSpeed = parseSpeed(avgSpeed);

    int speedPoint = 0;
    // Adding point for speed only if at least 1km has been runned
    if (distance >= 1) {
      if (parsedSpeed < 300) {
        speedPoint = 50;
      } else if (parsedSpeed >= 300 && parsedSpeed < 360) {
        speedPoint = 25;
      } else if (parsedSpeed >= 360 && parsedSpeed < 420) {
        speedPoint = 15;
      }
    }

    return kmPoints + bonusPoints + speedPoint;
  }

  Future<void> updateUserRank(double distance, String avgSpeed) async {
    int newRankValue = computePoints(distance, avgSpeed);
    await userDoc.set(
        {"rank": FieldValue.increment(newRankValue)}, SetOptions(merge: true));
  }

  Stream<int> getUserRank() {
    return userDoc.snapshots().map((snapshot) {
      return (snapshot.data() as Map<String, dynamic>)['rank'] as int? ?? 0;
    });
  }

}
