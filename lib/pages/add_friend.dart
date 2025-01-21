import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motivate_me/ui/colors.dart';

class AddFriends extends StatefulWidget {
  @override
  _AddFriendsState createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String searchedUsername = "";
  TextEditingController _controller = TextEditingController();
  List<String> currentFriends = [];

  void addFriend(String uid, String friendUid) async {
    try {
      await firestore.collection('users').doc(friendUid).update({
        "friendsRequest": FieldValue.arrayUnion([uid])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: CustomColors().primaryGreen,
          behavior: SnackBarBehavior.floating,
          content: const Text("Friend request sent !",style: TextStyle(color: Colors.black),)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: CustomColors().primaryRed,
          behavior: SnackBarBehavior.floating,
          content: const Text("Something went wrong ...",style: TextStyle(color: Colors.white),)),
      );
    }
  }

  Future<void> fetchCurrentFriends() async {
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(auth.currentUser!.uid).get();
    setState(() {
      currentFriends = List<String>.from(userDoc['friends'] ?? []);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCurrentFriends();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      appBar: AppBar(
        title: const Text(
          "ADD FRIENDS",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: CustomColors().secondaryGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          SizedBox(
            width: width * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "Search for a username",
                        hintStyle:
                            TextStyle(color: CustomColors().tertiaryGrey),
                        fillColor: Colors.white,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: CustomColors().primaryGreen))),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: CustomColors().primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        searchedUsername = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return SizedBox(
                height: height * 0.7,
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    if (snapshot.data!.docs[index].id ==
                            auth.currentUser!.uid ||
                        currentFriends
                            .contains(snapshot.data!.docs[index].id)) {
                      return const SizedBox.shrink();
                    }
                    if (searchedUsername.isEmpty ||
                        data["username"]
                            .toString()
                            .startsWith(searchedUsername)) {
                      return ListTile(
                        title: Text(
                          data['username'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            addFriend(auth.currentUser!.uid,
                                snapshot.data!.docs[index].id);
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
