import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmedia_app/LoginPage.dart';

class registration extends StatefulWidget {
  const registration({Key? key});

  @override
  State<registration> createState() => _registrationState();
}

class _registrationState extends State<registration> {
  File? selectedImage;
  TextEditingController regUserName = TextEditingController();
  TextEditingController regEmilid = TextEditingController();
  TextEditingController regPassword = TextEditingController();
  TextEditingController regbio = TextEditingController();
  bool loading = false;
  String? ImageUrl;
  final FirebaseStorage _Storage = FirebaseStorage.instance;

  Future<void> _userRegistration() async {
    try {
      setState(() {
        loading = true;
      });

      // user creation through email
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: regEmilid.text, password: regPassword.text);
      if (selectedImage != null) {
        final ImageRef = _Storage.ref().child(
            'user_image/${userCredential.user!.uid}.jpg'); //saving image to firebase storage in user_image folder as userid.jpg
        final UploadTask uploadTask = ImageRef.putFile(selectedImage!);
        final TaskSnapshot storageTaskSnapshot = await uploadTask;
        final String ImageUrltemp = await storageTaskSnapshot.ref
            .getDownloadURL(); // save chyitha image inte url downloding to put it in user db
        setState(() {
          ImageUrl =
              ImageUrltemp; //image saved int url setting to this variable
        });
      }
      if (userCredential.user != null) {
        // Save user details to Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "username": regUserName.text,
          "Email": regEmilid.text,
          "bio": regbio.text,
          'image_url': ImageUrl, //saving image link to user db
          'followers': [],
          'mefollowing': [],
        });
        //after login go to login screen
        setState(() {
          loading = false;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return loginPage();
        }));
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      print("Registration Error: ${e.toString()}");
    }
  }

  Future<void> getImage() async {// this function is to accept image and dispaly it in the registraion page after uploading
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SizedBox(height: 35,),
            Container(
              child: Text(
                "Instagram",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .01,
            ),
            InkWell(
              onTap: () {
                getImage();
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: selectedImage != null
                    ? CircleAvatar(
                        maxRadius: 40,
                        backgroundImage: FileImage(selectedImage!),//displaying image to reg after uploadingt 
                      )
                    : CircleAvatar(
                        maxRadius: 40,
                        backgroundColor: const Color.fromARGB(255, 207, 206, 206),
                        child: Icon(
                          Icons.person_add_alt,
                          size: 50,
                        ),
                      ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: regUserName,
                  decoration: InputDecoration(
                      hintText: "Enter your Username",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5))),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: regEmilid,
                decoration: InputDecoration(
                    hintText: "Enter your Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: regPassword,
                decoration: InputDecoration(
                    hintText: "Enter your Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: regbio,
                decoration: InputDecoration(
                    hintText: "Enter your bio ",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.06,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue), // Change color to blue
                ),
                onPressed: () {
                  _userRegistration();
                },
                child: loading != false
                    ? CircularProgressIndicator()
                    : Text("Register"),
              ),
            ),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you already a user ?",
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    " Sign in",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
