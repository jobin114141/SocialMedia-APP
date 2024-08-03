import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia_app/other%20pages/ChatPage.dart';

class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage({super.key});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  // Map<String, dynamic> userMap;
  late User? currentUser;
  TextEditingController SearchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  List<DocumentSnapshot> users = [];
  String? myUserName;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void getCurrentUser() {
    final user = auth.currentUser;

    FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          myUserName = documentSnapshot['username'];
        });
      }
    });
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
    return Scaffold(appBar: AppBar(title: Text("MESSAGES"),),
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
                  // final bio = userData['bio'] ?? '';
                  final ImageUrl = userData['image_url'] ?? '';
                  // final followers = userData['followers'] ?? [];
                  // final mefollowing = userData['mefollowing'] ?? [];
                  // Skip the current user's data
                  if (currentUser?.uid == userId) {
                    return SizedBox.shrink(); // or any other widget you prefer
                  }

                  return InkWell(
                    onTap: () {
                      String roomId = chatRoomId(myUserName!, username);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ChatPage(
                              uid: "$userId",
                              chatRoomId: roomId,
                              hisusername: username,
                              myUserName: myUserName!,Imag:ImageUrl)));
                    },
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
                        trailing:Icon(Icons.message),
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
