import 'dart:async';
import 'dart:math';

import 'package:elaf/Assistants/RequestAssistants.dart';
import 'package:elaf/DataHandler/AppData.dart';
import 'package:elaf/Models/Address.dart';
import 'package:elaf/Models/AllUsers.dart';
import 'package:elaf/Models/DirectionDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:elaf/configMaps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AssistantsMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        // "https://maps.googleapis.com/maps/api/geocode/json?latlng=$position.latitude,$position.longitude&key=$mapKey";
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=36.1892142,44.0088699&key=$mapKey";

    var response = await RequestAssistants.getRequest(url);

    if (response != "Failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = "$st1,$st2,$st3,$st4";

      Address userPickupAddress = Address();
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> getPlaceDirectionDetails(
      LatLng iPosision, LatLng fPosision) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${iPosision.latitude},${iPosision.longitude}&destination=${fPosision.latitude},${fPosision.longitude}&key=$mapKey";
    var res = await RequestAssistants.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails details = DirectionDetails();
    details.encodedPoints = res["routes"][0]["overview_polyline"]["points"];
    details.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    details.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    details.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    details.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return details;
  }

  static String calculateFares(DirectionDetails details) {
    double timeTravelFare = (details.durationValue / 60) * 0.20;
    double distanceTravelFare = (details.distanceValue / 1000) * 0.20;
    double total = distanceTravelFare + timeTravelFare;
    double exchangeRate = 1460; // 1 USD = 1460 IQD
    double fareInIQD = total * exchangeRate;

    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(fareInIQD);
  }


  static void getCurrentOnlineUser() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userID = firebaseUser?.uid;
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("users").child(userID!);
    reference.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
        userCurrentInfo = Users.fromSnapshot(snapshot);
      }
    } as FutureOr Function(DatabaseEvent value)).catchError((error) {
      print("Error: $error");
    });
  }


  static double createRandomNumber(int num){
    var random = Random();
    int radNum = random.nextInt(num);
    return radNum.toDouble();
    
  }




}
