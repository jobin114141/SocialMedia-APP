import 'package:flutter/material.dart';
import 'package:socialmedia_app/other%20pages/Homepage.dart';
import 'package:socialmedia_app/other%20pages/addPostPage.dart';
import 'package:socialmedia_app/other%20pages/favPage.dart';
import 'package:socialmedia_app/other%20pages/profilePage.dart';
import 'package:socialmedia_app/other%20pages/searchPage.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final List<Widget> otherPages = [
    HomePage(),
    SearchPage(),
    AddPostPage(),
    FavPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
      body: otherPages[currentIndex],
    );
  }
}
