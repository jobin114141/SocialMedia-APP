import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ViewFriendProfile extends StatefulWidget {
  final String uid;
  const ViewFriendProfile({Key? key, required this.uid}) : super(key: key);

  @override
  State<ViewFriendProfile> createState() => _ViewFriendProfileState();
}

class _ViewFriendProfileState extends State<ViewFriendProfile> {
  late User CurrentUser;
  String? UserName;
  String? Bio;
  String? FollowerCount;
  String? FollowingCount;
  String? ProfileUrl;
  List<String> PostImageurls = [];
  String? ImageCount;
  // ignore: unused_field
  bool _isLoading = false;
  late bool isFollowing = false;
  @override
  void initState() {
    //Getting current user object
    CurrentUser = FirebaseAuth.instance.currentUser!;
    //To documentSnapshot we are saving a collection called users having document namde in current user uid.
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          UserName = documentSnapshot['username'];
          Bio = documentSnapshot['bio'];
          FollowerCount = documentSnapshot["followers"].length.toString();
          FollowingCount = documentSnapshot["mefollowing"].length.toString();
        });
      }
    });
    //Geting image for profile.in fire basestorage i saved like in a folder user_image/inside current user id.
    final storageRef =
        FirebaseStorage.instance.ref().child('user_image/${widget.uid}.jpg');
    storageRef.getDownloadURL().then((url) {
      setState(() {
        ProfileUrl = url;
        print(ProfileUrl);
      });
    });
    checkFollowingStatus();
    GetPostImages();
    super.initState();
  }

  Future<void> GetPostImages() async {
    try {
      FirebaseFirestore.instance
          .collection("posts")
          .where('user_id', isEqualTo: widget.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          List<String> imgurls = [];
          querySnapshot.docs.forEach(
            (itemss) {
              imgurls.add(itemss['image_url']);
            },
          );
          setState(() {
            PostImageurls = imgurls;
            ImageCount = PostImageurls.length.toString();
          });
        }
      });
    } catch (e) {
      print("$e");
    }
  }

  Future<void> checkFollowingStatus() async {
    try {
      // Get the current user's ID
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

      // Get the profile's document reference
      DocumentReference profileRef =
          FirebaseFirestore.instance.collection("users").doc(widget.uid);

      // Get the document snapshot of the profile
      DocumentSnapshot profileSnapshot = await profileRef.get();

      // Check if the current user is in the followers list of the profile
      bool isFollowingProfile =
          profileSnapshot['followers'].contains(currentUserUid);

      setState(() {
        isFollowing = isFollowingProfile;
      });
    } catch (e) {
      print("Error checking following status: $e");
    }
  }

  Future<void> UnfollowFun() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      final user = _auth.currentUser;
      if (user == null) {
        return print("User not logged in.");
      }
      final currentUserUid = user.uid;
      final followedUserId = widget.uid.toString();

      final followedUserRef =
          FirebaseFirestore.instance.collection("users").doc(followedUserId);
      await followedUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserUid])
      });

      final currentUserRef =
          FirebaseFirestore.instance.collection("users").doc(currentUserUid);
      await currentUserRef.update({
        'mefollowing': FieldValue.arrayRemove([followedUserId])
      });

      // Update follower count locally
      setState(() {
        FollowerCount = (int.parse(FollowerCount ?? '0') - 1).toString();
      });

      // Update isFollowing to false
      setState(() {
        isFollowing = false;
      });
    } catch (e) {
      print("Error unfollowing user: $e");
    }
  }

  Future<void> FollowFun() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      final user = _auth.currentUser;
      if (user == null) {
        return print("User not logged in.");
      }
      final currentUserUid = user.uid;
      final followedUserId = widget.uid.toString();

      final followedUserRef =
          FirebaseFirestore.instance.collection("users").doc(followedUserId);
      await followedUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserUid])
      });

      final currentUserRef =
          FirebaseFirestore.instance.collection("users").doc(currentUserUid);
      await currentUserRef.update({
        'mefollowing': FieldValue.arrayUnion([followedUserId])
      });

      // Update follower count locally
      setState(() {
        FollowerCount = (int.parse(FollowerCount ?? '0') + 1).toString();
      });
      setState(() {
        isFollowing = true;
      });
    } catch (e) {
      print("Error following user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              color: const Color.fromARGB(255, 41, 41, 41),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "$UserName",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: ProfileUrl != null
                              ? NetworkImage(ProfileUrl!)
                              : NetworkImage(
                                  'https://example.com/default_profile_image.jpg'),
                        ),
                        Column(
                          children: [Text('$FollowerCount'), Text('Followers')],
                        ),
                        Column(
                          children: [
                            Text(ImageCount != null ? "$ImageCount" : "0"),
                            Text('Posts')
                          ],
                        ),
                        Column(
                          children: [
                            Text(FollowingCount != null &&
                                    int.parse(FollowingCount!) > 0
                                ? FollowingCount!
                                : '0'),
                            Text('Following')
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          "$Bio",
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 110),
                          child: InkWell(
                            onTap: () {
                             isFollowing ? UnfollowFun() : FollowFun();
                            },
                            child: SizedBox(
                              height: 40,
                              width: 205,
                              child: Container(
                                color: Colors.blue,
                                child: Center(
                                  child:
                                      Text(isFollowing ? "Unfollow" : "Follow"),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
          Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: PostImageurls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      PostImageurls[index],
                      fit: BoxFit.cover,
                    );
                  }))
        ],
      ),
    );
  }
}
