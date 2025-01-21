import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RunHistoryService {
  /* Service to run history operations */
  final User currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final DocumentReference userDoc;

  RunHistoryService(this.currentUser) {
    userDoc = firestore.collection('runHistory').doc(currentUser.uid);
  }
  Future<void> addRun(Map<String, dynamic> runData) async {
    await userDoc.collection('runs').doc().set(runData);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getRunHistory() async {
    return await userDoc.collection('runs').get();
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getRunHistoryStream() {
    return  userDoc.collection('runs').orderBy('date',descending: true).snapshots();
  }
  Future<Object?> getLatestRun() async {
    QuerySnapshot snapshot = await userDoc.collection('runs').orderBy('date',descending: true).get();
    return snapshot.docs[0].data();
  }

}
