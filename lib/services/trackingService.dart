import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackingService{
  final User currentUser;
  final FirebaseDatabase db = FirebaseDatabase.instance;
  TrackingService(this.currentUser);

  

}