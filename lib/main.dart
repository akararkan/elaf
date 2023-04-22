import 'package:elaf/AllScreen/LoginScreen.dart';
import 'package:elaf/AllScreen/MainScreen.dart';
import 'package:elaf/AllScreen/RegistrationScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve Firebase options from a configuration file or environment variables
  FirebaseOptions options = const FirebaseOptions(
    projectId: "elaf-9df7c",
    apiKey: "AIzaSyDgePtHpf54xvNThnzZjvVj9xVyMVr_lik",
    appId: "1:51236179516:android:189a39d3c31d7b8babfd39",
    messagingSenderId: '1:51236179516:android:189a39d3c31d7b8babfd39',
    databaseURL: "https://elaf-9df7c-default-rtdb.firebaseio.com/",

  );

  await Firebase.initializeApp(
      name: "elaf",
      options: options);


  runApp(const MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هههههه ئاکار',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: LoginScreen.login,
      routes: {
        RegistrationScreen.register: (context) => RegistrationScreen(),
        LoginScreen.login: (context) => LoginScreen(),
        MainScreen.main: (context) =>  MainScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
