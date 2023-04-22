import 'package:elaf/AllScreen/LoginScreen.dart';
import 'package:elaf/AllScreen/MainScreen.dart';
import 'package:elaf/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../AllWidgets/ProgressDialog.dart';

class RegistrationScreen extends StatelessWidget {
  static const String register = "register";
  TextEditingController nametec = TextEditingController();
  TextEditingController emailtec = TextEditingController();
  TextEditingController phonetec = TextEditingController();
  TextEditingController passowrdtec = TextEditingController();

  RegistrationScreen({super.key});

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
                "Register as Rider",
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
                      controller: nametec,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
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
                      controller: phonetec,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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
                          if (nametec.text.length < 4) {
                            displayToastMessage(
                                "Name character must be grater than 4",
                                context);
                          } else if (!emailtec.text.contains("@")) {
                            displayToastMessage("Email is not valid", context);
                          } else if (phonetec.text.isEmpty) {
                            displayToastMessage(
                                "Phone number is required", context);
                          } else if (passowrdtec.text.length < 7) {
                            displayToastMessage(
                                "Password must be at least 8 character",
                                context);
                          } else {
                            registerNewUser(context);
                          }
                          print("Register Button Pressed");
                        },
                        child: Text('Register'),
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
                        context, LoginScreen.login, (route) => false);
                    print("Already Have Account button pressed");
                  },
                  child: Text(
                    "Already Have Account",
                    style: TextStyle(color: Colors.amber[900]),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  // user registration method
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Registration Process.....");
        }
    );
    final User? user = (await _firebaseAuth
        .createUserWithEmailAndPassword(
        email: emailtec.text, password: passowrdtec.text)
        .catchError((errMSG) {
      Navigator.pop(context);

      displayToastMessage("Error: $errMSG", context);
    }))
        .user;

    if (user != null) {
// save user into database
      Map userDataMap = {
        "name": nametec.text.trim(),
        "email": emailtec.text.trim(),
        "phone": phonetec.text.trim()
      };
      userRef.child(user.uid).set(userDataMap);
      displayToastMessage(
          "Your Account Has been created Successfully", context);
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.login, (route) => false);
    } else {
      Navigator.pop(context);

      displayToastMessage("No user a ccount has not been created", context);
    }
  }
}
// to display the popup messages
displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
