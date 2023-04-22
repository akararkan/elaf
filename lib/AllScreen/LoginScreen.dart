import 'dart:async';

import 'package:elaf/AllScreen/RegistrationScreen.dart';
import 'package:elaf/AllWidgets/ProgressDialog.dart';
import 'package:elaf/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

class LoginScreen extends StatelessWidget {
  static const String login = "login";
  TextEditingController emailtec = TextEditingController();
  TextEditingController passowrdtec = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 45.0,
              ),
              Center(
                  child: Image(
                    image: AssetImage('images/taxi_logo.png'),
                    width: 250.0,
                    height: 250.0,
                  )),
              SizedBox(
                height: 15.0,
              ),
              Text(
                "Login as Rider",
                style: TextStyle(fontSize: 35, fontFamily: 'Pacifico'),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailtec,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                        TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passowrdtec,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                        TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: 50,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!emailtec.text.contains("@")) {
                            displayToastMessage("Email is not valid", context);
                          } else if (passowrdtec.text.isEmpty) {
                            displayToastMessage("Password is empty", context);
                          } else {
                            loginAuthUser(context);
                          }
                        },
                        child: Text('Login'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.yellow[900]!),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.register, (route) => false);
                    print("dont have account button pressed");
                  },
                  child: Text(
                    "Dont have account?",
                    style: TextStyle(color: Colors.amber[900]),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAuthUser(BuildContext context) async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Authentication Process.....");
        }
    );
    final User? user = (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailtec.text, password: passowrdtec.text)
        .catchError((errMSG) {
      Navigator.pop(context);
      displayToastMessage("Error: $errMSG", context);
    }))
        .user;

    if (user != null) {
      userRef.child(user.uid).once().then((event) {
        if (event.snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.main, (route) => false);
          displayToastMessage("Logged In Now", context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          print("No User Exists");
          displayToastMessage("Error: the user dosent exixts", context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage("Error Occured cannot be Signed in", context);
    }
  }
}
