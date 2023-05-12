import 'dart:math';

import 'package:elaf/AllWidgets/Divider.dart';
import 'package:elaf/AllWidgets/ProgressDialog.dart';
import 'package:elaf/Assistants/RequestAssistants.dart';
import 'package:elaf/DataHandler/AppData.dart';
import 'package:elaf/Models/Address.dart';
import 'package:elaf/Models/PlacePredictions.dart';
import 'package:elaf/configMaps.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickTxtEditor = TextEditingController();

  TextEditingController dropTxtEditor = TextEditingController();

  List<PlacePredictions> predictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickTxtEditor.text = placeAddress;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  spreadRadius: .5,
                  offset: Offset(.7, .7))
            ]),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 25, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style:
                              TextStyle(fontFamily: "Brand-Bold", fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/pick.png",
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickTxtEditor,
                              decoration: InputDecoration(
                                hintText: "PickUp Location",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/posimarker.png",
                        height: 20,
                        width: 20,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropTxtEditor,
                              decoration: InputDecoration(
                                hintText: "Where to",
                                fillColor: Colors.grey[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 11, top: 8, bottom: 8),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: 10,
          ),
          // prediction tile
          (predictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePredictions: predictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: predictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:iq";
      var res = await RequestAssistants.getRequest(autoCompleteUrl);

      if (res == "failed") {
        return;
      }
      print(res);
      print(
          "places predictions response ::----------------------------------------------------------------------");

      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placeList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          predictionList = placeList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  PredictionTile({Key? key, required this.placePredictions}) : super(key: key);

  final PlacePredictions placePredictions;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddress(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 9,
                      ),
                      Text(
                        placePredictions.main_text,
                        style: TextStyle(
                            fontSize: 16, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        placePredictions.secondary_text,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13,
                            color: Colors.grey),
                      ),
                      SizedBox(
                        height: 9,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddress(String placeID, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Setting Drop off..."));

    String placeDetails =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$mapKey";
    var res = await RequestAssistants.getRequest(placeDetails);

    Navigator.pop(context);

    if (res == "failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeID = placeID;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print(
          "------------------------------------------////////////////////////////////////////**************");
      print("this is drop off location::::  " + address.placeName);

      Navigator.pop(context, "ObtainDirection");
    }
  }
}
