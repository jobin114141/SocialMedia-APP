import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<QuerySnapshot> _postSnapshotFuture;
  late Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _postSnapshotFuture = FirebaseFirestore.instance.collection("posts").get();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection("users").get();
    usersSnapshot.docs.forEach((doc) {
      _userData[doc.id] = doc.data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _postSnapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final postSnapshot = snapshot.data!;
            return ListView.builder(
              itemCount: postSnapshot.size,
              itemBuilder: (context, index) {
                var document = postSnapshot.docs[index];
                var userData = _userData[document['user_id']] ?? {};
                var username = userData['username'] ?? 'Unknown';
                var profilePicUrl = userData['image_url'] ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(profilePicUrl),
                        ),
                        Text(username)
                      ],
                    ),
                    Container(
                      child: Image.network(
                        document['image_url'],
                        fit: BoxFit.cover,
                      ),
                      height: 300,
                      width: double.infinity,
                    ),
                    Row(
                      children: [
                        Container(
                            height: 40,
                            child: FittedBox(
                              child: Icon(
                                Icons.favorite,
                              ),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            height: 40,
                            child: FittedBox(
                              child: Icon(
                                Icons.messenger_outline_outlined,
                              ),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                            height: 40,
                            child: FittedBox(
                              child: Icon(
                                Icons.message,
                              ),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Spacer(),
                        Container(
                            height: 40,
                            child: FittedBox(
                              child: Icon(
                                Icons.bookmark_add_outlined,
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                    Text("0 likes"),
                    Text(
                      document['description'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "View all comments",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      "Aug 3, 2023",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    )
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
