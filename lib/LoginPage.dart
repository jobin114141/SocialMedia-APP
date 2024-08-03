import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:socialmedia_app/RegPage.dart';
import 'package:socialmedia_app/adminController/authcontroller.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  final ctrl = Get.put(Authcontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "Instagram",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: ctrl.loginemail,
                decoration: InputDecoration(
                    hintText: "Enter your Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: ctrl.loginpassword,
              decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .03),
          SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              height: MediaQuery.of(context).size.height * .06,
              child: Obx(
                () => ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.blue), // Change color to blue
                    ),
                    onPressed: () {
                      ctrl.signin(context);
                    },
                    child: ctrl.loading.value
                        ? CircularProgressIndicator()
                        : Text(
                            "login",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          )),
              )),
          SizedBox(
            height: 10,
          ),
          Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Are you new?",
              style: TextStyle(fontWeight: FontWeight.w200),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                  return registration();
                }));
              },
              child: Text(
                " Siginup",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ])),SizedBox(height: 10,),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return registration();
              }));
            },
            child: Text(
              " Forgot Your password ?",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
