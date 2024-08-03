import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String uid;
  final String chatRoomId;
  final String hisusername;
  final String myUserName;
  final String Imag;

  const ChatPage({
    Key? key,
    required this.uid,
    required this.chatRoomId,
    required this.hisusername,
    required this.myUserName,
    required this.Imag,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Size size;
  TextEditingController _message = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> onSendMessage() async {
    try {
      if (_message.text.isNotEmpty) {
        Map<String, dynamic> messages = {
          "sendby": widget.myUserName,
          "message": _message.text,
          "time": FieldValue.serverTimestamp(),
        };
        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .add(messages);
        _message.clear();
      } else {
        print("Enter some Text");
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size; // Initialize size here
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: widget.Imag != null
                  ? NetworkImage(widget.Imag!)
                  : NetworkImage(
                      'https://example.com/default_profile_image.jpg'),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.hisusername)
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy('time', descending: true)  // Sort messages by 'time' in descending order
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ListView.builder(
                    reverse: true,  // Reverse the list to display the latest message at the bottom
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? map =
                          snapshot.data!.docs[index].data() as Map<String,
                              dynamic>?; // Cast data to Map<String, dynamic>
                      if (map != null) {
                        return messages(size, map);
                      } else {
                        return SizedBox
                            .shrink(); // Return an empty SizedBox if the map is null
                      }
                    },
                  );
                } else {
                  return Center(
                    child: Text("No messages"),
                  );
                }
              },
            ),
          ),
          Container(
            height: size.height / 10,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              height: size.height / 12,
              width: size.width / 1.1,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: InputDecoration(
                        hintText: "Enter message",
                        suffixIcon: IconButton(
                          onPressed: () {
                            onSendMessage();
                          },
                          icon: Icon(Icons.send),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return Container(
      width: size.width,
      alignment: map['sendby'] == widget.myUserName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Color.fromRGBO(5, 248, 159, 1)),
        child: Text(
          map['message'],
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 19, 1, 1)),
        ),
      ),
    );
  }
}
