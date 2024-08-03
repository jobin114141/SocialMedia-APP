import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socialmedia_app/adminController/authcontroller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ctrl = Get.put(Authcontroller());
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
  @override
  void initState() {
    //Getting current user object
    CurrentUser = FirebaseAuth.instance.currentUser!;
    //To documentSnapshot we are saving a collection called users having document namde in current user uid.
    FirebaseFirestore.instance
        .collection("users")
        .doc(CurrentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          UserName = documentSnapshot['username'];
          Bio = documentSnapshot['bio'];
          FollowerCount=documentSnapshot["followers"].length.toString();
          FollowingCount=documentSnapshot["mefollowing"].length.toString();
        });
      }
    });
    //Geting image for profile.in fire basestorage i saved like in a folder user_image/inside current user id.
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_image/${CurrentUser.uid}.jpg');
    storageRef.getDownloadURL().then((url) {
      setState(() {
        ProfileUrl = url;
        print(ProfileUrl);
      });
    });
    GetPostImages();
    super.initState();
  }

  Future<void> GetPostImages() async {
    try {
      FirebaseFirestore.instance
          .collection("posts")
          .where('user_id', isEqualTo: CurrentUser.uid)
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
                          children: [Text(FollowerCount != null &&
                                    int.parse(FollowerCount!) > 0
                                ? FollowerCount!
                                : '0'),
                            Text('Followers')],
                         
                        ),
                        Column(
                          children: [Text(ImageCount!=null?"$ImageCount":"0"), Text('Posts')],
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
                              ctrl.signout(context);
                            },
                            child: SizedBox(
                              height: 40,
                              width: 205,
                              child: Container(
                                color: Colors.blue,
                                child: Center(child: Text("SignOut")),
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
