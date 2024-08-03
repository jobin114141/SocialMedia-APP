import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia_app/other%20pages/viewFriendsProfile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late User? currentUser;
  TextEditingController SearchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  List<DocumentSnapshot> users = [];
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  void getCurrentUser() {
    final user = auth.currentUser;
    setState(() {
      currentUser = user;
    });
  }

  void getUsers() {
    FirebaseFirestore.instance.collection("users").get().then((querySnapshot) {
      setState(() {
        users = querySnapshot.docs;
      });
    });
  }

  List<DocumentSnapshot> filteredUsers() {
    String SearchItm = SearchController.text.toLowerCase();
    List<DocumentSnapshot> filteredList = [];
    for (DocumentSnapshot item in users) {
      String username = item['username'].toString().toLowerCase();
      if (username.contains(SearchItm)) {
        filteredList.add(item);
      }
    }

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: 400,
              height: 60,
              child: TextField(
                controller: SearchController,
                decoration: InputDecoration(
                    hintText: "Search", border: OutlineInputBorder()),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild when text changes
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers().length,
                itemBuilder: (context, index) {
                  final user = filteredUsers()[index];
                  final userId = user.id;
                  final userData = user.data() as Map<String, dynamic>;
                  final username = userData['username'] ?? '';
                  final Email = userData['Email'] ?? '';
                  final bio = userData['bio'] ?? '';
                  final ImageUrl = userData['image_url'] ?? '';
                  final followers = userData['followers'] ?? [];
                  final mefollowing = userData['mefollowing'] ?? [];
                  // Skip the current user's data
                  if (currentUser?.uid == userId) {
                    return SizedBox.shrink(); // or any other widget you prefer
                  }

                  return InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ViewFriendProfile(
                              uid: "$userId",
                            ))),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: ImageUrl != null
                              ? NetworkImage(ImageUrl!)
                              : NetworkImage(
                                  'https://example.com/default_profile_image.jpg'),
                        ),
                        title: Text(username),
                        subtitle: Text(Email),
                        trailing: Text(bio),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
