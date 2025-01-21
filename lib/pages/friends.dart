import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motivate_me/services/friendService.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/pages/add_friend.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late FriendService friendService;

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    friendService = FriendService(auth.currentUser!);
  }

  @override
  Widget build(BuildContext context) {
    double width = getWidth(context);
    double height = getHeight(context);

    return Scaffold(
      backgroundColor: CustomColors().secondaryGrey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors().primaryBlue,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddFriends()));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.1,
            ),
            const Text(
              "FRIENDS",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
            SizedBox(height: height*0.05,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("REQUEST",style:TextStyle(color:Colors.white,fontSize: 17,fontWeight: FontWeight.bold)),
                Divider(color: CustomColors().tertiaryGrey,),
                StreamBuilder(
                    stream: friendService.getFriendsRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return SizedBox(
                            width: width,
                            height: height * 0.4,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var data = snapshot.data!;
                                return Column(children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: Image.network(
                                                data[index]["profilePic"],
                                                height: 40),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(data[index]["username"])
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              friendService.declineFriendRequest(
                                                  data[index]['uid']);
                                            },
                                            icon: const Icon(Icons.close),
                                            color: Colors.red,
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                friendService.acceptFriendRequest(
                                                    data[index]['uid']);
                                              },
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Divider()
                                ]);
                              },
                            ),
                          );
                        }
                      }
                      return const Center(child: Text("No friends requests",style: TextStyle(color: Colors.white),));
                    }),
              ],
            ),
            SizedBox(height: height*0.1,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ALL",style:TextStyle(color:Colors.white,fontSize: 17,fontWeight: FontWeight.bold)),
                Divider(color: CustomColors().tertiaryGrey,),
                StreamBuilder(
                    stream: friendService.getUsersFriendsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          width: width,
                          height: height * 0.4,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var data = snapshot.data!;
                              return Column(children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                          data[index]["profilePic"],
                                          height: 40),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[index]["username"],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("Stats soon...",style: TextStyle(color: CustomColors().tertiaryGrey,fontSize: 10),)
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15,)
                              ]);
                            },
                          ),
                        );
                      }
                      return const Center(child: Text("No friends...",style: TextStyle(color: Colors.white),));
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
