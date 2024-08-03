import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> PostImageurls = [];

  @override
  void initState() {
    GetPostImages();
    super.initState();
  }

  Future<void> GetPostImages() async {
    try {
      FirebaseFirestore.instance
          .collection("posts")
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
          });
        }
      });
    } catch (e) {
      print("$e");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 250,
          leading: Text(
            " Instagram",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () async {},
              child: Icon(Icons.message),
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: PostImageurls.length,
            itemBuilder: (context, index) {
              return buildCard(index);
            }));
  }

  Widget buildCard(int index) => ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Image.network(
                  PostImageurls[index],
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
                "Aloha shama",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
          ),
        ),
      );
}
