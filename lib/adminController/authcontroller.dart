import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmedia_app/LoginPage.dart';
import 'package:socialmedia_app/other%20pages/bottomNavBar.dart';


class Authcontroller extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController loginemail = TextEditingController();
  TextEditingController loginpassword = TextEditingController();
  TextEditingController resetemail = TextEditingController();
  var loading = false.obs;
  
  XFile? imageFile;

  signout(BuildContext context) async {
    await auth.signOut();
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("email");
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => loginPage()));
  }

  signin(BuildContext context) async {
    try {
      loading.value = true;
      await auth.signInWithEmailAndPassword(
          email: loginemail.text, password: loginpassword.text);
      Shrdprfs();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => BottomNavBar()));
      loading.value = false;
     
    } catch (e) {
      Get.snackbar("error", "$e");
      loading.value = false;
    }
  }

  verifyEmial() async {
    await auth.currentUser?.sendEmailVerification();
    Get.snackbar("email", "send");
  }
  Shrdprfs()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("email", loginemail.text);
  }

}
