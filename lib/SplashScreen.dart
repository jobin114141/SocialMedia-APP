import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialmedia_app/LoginPage.dart';
import 'package:socialmedia_app/other%20pages/BottomNavBar.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    getValidationData().whenComplete(() async {
      Timer(Duration(seconds: 2), () {
        if (finalEmail == null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
            return loginPage();
          }));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
            return BottomNavBar();
          }));
        }
      });
    });
    super.initState();
  }

  String? finalEmail;

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString("email");
    setState(() {
      finalEmail = obtainedEmail;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color:Colors.red)
          ],
        ),
      ),
    );
  }
}
