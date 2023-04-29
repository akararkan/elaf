import 'package:firebase_database/firebase_database.dart';

class Users {
  String id = "";
  String email = "";
  String name = "";
  String phone = "";

  Users(
      {required this.id,
      required this.email,
      required this.name,
      required this.phone});

  Users.fromSnapshot(DataSnapshot snapshot) :
        id = snapshot.key!,
        email = (snapshot.value as Map<String, dynamic>)["email"] as String,
        name = (snapshot.value as Map<String, dynamic>)["name"] as String,
        phone = (snapshot.value as Map<String, dynamic>)["phone"] as String;

}
