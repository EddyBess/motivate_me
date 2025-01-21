import 'package:flutter/material.dart';
import 'package:motivate_me/ui/colors.dart';
import 'package:motivate_me/utils/size.dart';
import 'package:motivate_me/utils/colors.dart';

class FriendsSelector extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final Function(Map<String, dynamic>?) onFriendSelected;

  const FriendsSelector({
    required this.friends,
    required this.onFriendSelected,
    super.key,
  });

  @override
  State<FriendsSelector> createState() => _FriendsSelectorState();
}

class _FriendsSelectorState extends State<FriendsSelector> {
  Map<String, dynamic>? selectedFriend;

  @override
  void didUpdateWidget(FriendsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (selectedFriend != null && !widget.friends.contains(selectedFriend) && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFriendSelected(null);
        selectedFriend = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = getHeight(context);
    double width = getWidth(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.3),
        //     spreadRadius: 2,
        //     blurRadius: 8,
        //     offset: const Offset(2, 2), // Shadow position
        //   ),
        // ],
      ),
      child: SizedBox(
        height: height * 0.3,
        width: width * 0.15,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.black,
            child: Column(
              children: widget.friends.map((friend) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFriend = friend;
                    });
                    widget.onFriendSelected(friend);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.01),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedFriend == friend ? CustomColors().primaryGreen : Colors.transparent,
                          width: 2, // Thickness of the selection border
                        ),
                      ),
                      child: CircleAvatar(
                        radius: width * 0.05,
                        backgroundImage: NetworkImage(friend['profilePic']),
                        backgroundColor: Colors.grey.shade200,
                        onBackgroundImageError: (_, __) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
