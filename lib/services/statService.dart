import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatService {
  /* Service to manage user rank-related operations */
  final User currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  StatService(this.currentUser);

  Future<void> updateUserTotalDistance(double distance) async {
    await firestore
        .collection('stats')
        .where("uid", isEqualTo: currentUser.uid)
        .limit(1)
        .get()
        .then((query) => firestore
            .collection('stats')
            .doc(query.docs.first.id)
            .update({"totalDistance": FieldValue.increment(distance)}));
  }

  Future<double> _calculateDistanceWithinRange(DateTime start, DateTime end) async {
    final runsSnapshot = await firestore
        .collection('runHistory')
        .doc(currentUser.uid)
        .collection('runs')
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThanOrEqualTo: end)
        .get();

    double totalDistance = 0.0;
    for (var doc in runsSnapshot.docs) {
      totalDistance += (doc.data()['distance'] ?? 0.0) as double;
    }

    return totalDistance;
  }

  Future<void> updateLast7DaysDistance() async {
    final now = DateTime.now();
    final last7DaysStart = now.subtract(const Duration(days: 7));
    final totalDistance = await _calculateDistanceWithinRange(last7DaysStart, now);

    await firestore
        .collection('stats')
        .where("uid", isEqualTo: currentUser.uid)
        .limit(1)
        .get()
        .then((query) => firestore
            .collection('stats')
            .doc(query.docs.first.id)
            .update({"last7DaysDistance": totalDistance}));
  }

  Future<void> updateLastMonthDistance() async {
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, now.day);
    final totalDistance = await _calculateDistanceWithinRange(lastMonthStart, now);

    await firestore
        .collection('stats')
        .where("uid", isEqualTo: currentUser.uid)
        .limit(1)
        .get()
        .then((query) => firestore
            .collection('stats')
            .doc(query.docs.first.id)
            .update({"lastMonthDistance": totalDistance}));
  }
}
