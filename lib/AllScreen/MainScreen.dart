import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:elaf/AllScreen/LoginScreen.dart';
import 'package:elaf/AllScreen/SreachScreen.dart';
import 'package:elaf/AllWidgets/Divider.dart';
import 'package:elaf/Assistants/AssistantMethods.dart';
import 'package:elaf/Assistants/GeoFireAssistants.dart';
import 'package:elaf/DataHandler/AppData.dart';
import 'package:elaf/AllScreen/FeedbackDialog.dart';
import 'package:elaf/Models/DirectionDetails.dart';
import 'package:elaf/Models/NearbyDrivers.dart';
import 'package:elaf/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../AllWidgets/ProgressDialog.dart';

class MainScreen extends StatefulWidget {
  static const String main = "main";

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.1922, 44.0109), // set the latitude and longitude of Iraq
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails = DirectionDetails();

  List<LatLng> pLineCoordinate = [];
  Set<Polyline> polylineSet = {};

  double rideDetailsContainerHeight = 0;
  double reqRideContainerHeight = 0;
  double searchContainerHeight = 300;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeys = false;
  BitmapDescriptor? nearbyIcon;
  late DatabaseReference rideRequestReference;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantsMethods.getCurrentOnlineUser();
  }

  void saveRideRequest() {
    rideRequestReference =
        FirebaseDatabase.instance.ref().child("Rdise Request").push();
    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString()
    };
    Map dropOffMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString()
    };
    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpMap,
      "dropoff": dropOffMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo?.name,
      "rider_phone": userCurrentInfo?.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName
    };
    rideRequestReference.set(rideInfoMap);
  }

  void cancelRideRequest() {
    rideRequestReference.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      reqRideContainerHeight = 250;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 300;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      reqRideContainerHeight = 0;
      bottomPaddingOfMap = 300;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinate.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPLaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 250;
      bottomPaddingOfMap = 300;
      drawerOpen = false;
    });
  }

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  void locatePosition() async {
    // Check if the app has permission to access the device's location
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Request permission to access the device's location
      await Permission.location.request();
      // Check if the user granted permission
      status = await Permission.location.status;
      if (status.isDenied) {
        // Handle case where the user denied permission
        return;
      }
    }

    // Get the device's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantsMethods.searchCoordinateAddress(position, context);
    print(
        "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@this is your address ::" +
            address);
    initGeoFireListener();
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text("Main Screen"),
      ),
      drawer: Container(
        color: Colors.white,
        width: 300,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset('images/user.png'),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),
                          ),
                          Text(
                            "Visit Profile",
                            style: TextStyle(
                                fontSize: 17, fontFamily: 'Brand-Bold'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12,
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.login, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.signpost_outlined),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 400;
              });

              locatePosition();
            },
          ),

          //hamburger button for the drawer
          Positioned(
            top: 38,
            left: 22,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState?.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 6,
                          spreadRadius: .5,
                          offset: Offset(.7, .7))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20,
                ),
              ),
            ),
          ),
          //body screen
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 160),
              curve: Curves.bounceIn,
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 16,
                          spreadRadius: 0.5,
                          offset: Offset(.7, .7))
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Hi There",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      Text(
                        "Where to?",
                        style:
                            TextStyle(fontSize: 24.0, fontFamily: "Brand-Bold"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "ObtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7))
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.yellow.shade800,
                                ),
                                Text("Search for Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Provider.of<AppData>(context)
                                          .pickUpLocation !=
                                      null
                                  ? Provider.of<AppData>(context)
                                      .pickUpLocation
                                      .placeName
                                  : "Add home"),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your Living Address",
                                style: TextStyle(
                                    color: Colors.grey[750], fontSize: 12.0),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DividerWidget(),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your Office Address",
                                style: TextStyle(
                                    color: Colors.grey[750], fontSize: 12.0),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          //
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 160),
              curve: Curves.bounceIn,
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 16,
                          spreadRadius: .5,
                          offset: Offset(.7, .7)),
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.yellow[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/car.png",
                                height: 70,
                                width: 80,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: "Brand-Bold"),
                                  ),
                                  Text(
                                    ((tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : 'somewhat KM'),
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 80.0),
                                    child: Text(
                                      (tripDirectionDetails != null)
                                          ? '\IQD${AssistantsMethods.calculateFares(tripDirectionDetails)}'
                                          : 'somewhat IQD',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckDollar,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text("Cash"),
                            SizedBox(
                              width: 6,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.yellow[900]!),
                          ),
                          onPressed: () {
                            displayRequestRideContainer();
                            print("taxi requested");
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Send Feedback'),
                                  content: FeedbackDialog(riderID: firebaseUser?.uid),
                                );
                              },
                            );

                          },
                          child: Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request Taxi",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: .5,
                    blurRadius: 16,
                    color: Colors.black54,
                    offset: Offset(.7, .7),
                  ),
                ],
              ),
              height: reqRideContainerHeight,
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Requesting a Ride...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Please wait ...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Finding a driver',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border:
                                Border.all(width: 2, color: Colors.grey[300]!)),
                        child: Icon(
                          Icons.close,
                          size: 29,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Brand-Bold",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPLaceDirection() async {
    var iPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var fPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(iPos.latitude, iPos.longitude);
    var dropOffLatLng = LatLng(fPos.latitude, fPos.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: " Please wait ..."),
    );

    var details = await AssistantsMethods.getPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details!;
    });
    Navigator.pop(context);

    print(
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    print(details?.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPoint =
        polylinePoints.decodePolyline(details!.encodedPoints);

    pLineCoordinate.clear();
    if (decodedPoint.isNotEmpty) {
      decodedPoint.forEach((PointLatLng pointLatLng) {
        pLineCoordinate
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("PolyLineID"),
          jointType: JointType.round,
          points: pLineCoordinate,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: iPos.placeName, snippet: "my location"),
        position: pickUpLatLng,
        markerId: MarkerId("PickUp ID"));
    Marker dropOffMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: fPos.placeName, snippet: "Drop OFF Location"),
        position: dropOffLatLng,
        markerId: MarkerId("Drop OFF ID"));

    setState(() {
      markersSet.add(pickMarker);
      markersSet.add(dropOffMarker);
    });

    Circle pickCircle = Circle(
        fillColor: Colors.yellow,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.yellowAccent,
        circleId: CircleId("PickUp ID"));
    Circle dropOffCircle = Circle(
        fillColor: Colors.red,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.purple,
        circleId: CircleId("Drop OFF ID"));

    setState(() {
      circlesSet.add(pickCircle);
      circlesSet.add(dropOffCircle);
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarkers = <Marker>{};
    for (NearbyDrivers drivers in GeoFireAssistants.nearbyDriversList) {
      LatLng driverAvailablePosition =
          LatLng(drivers.latitude, drivers.longitude);
      Marker marker = Marker(
          markerId: MarkerId('drivers${drivers.key}'),
          position: driverAvailablePosition,
          icon: nearbyIcon!,
          rotation: AssistantsMethods.createRandomNumber(360));
      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDriver");

    double latitude = 36.1922;
    double longitude = 44.0109;
    double radius = 15.0;

    Geofire.queryAtLocation(latitude, longitude, radius)?.listen((map) {
      print('GeoFire query result: $map');
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDrivers nearbyDrivers = NearbyDrivers();
            nearbyDrivers.key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];
            GeoFireAssistants.nearbyDriversList.add(nearbyDrivers);
            if (nearbyAvailableDriverKeys == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistants.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyDrivers nearbyDrivers =
                NearbyDrivers(latitude: 36.1922, longitude: 44.0109, key: '');
            nearbyDrivers.key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];
            GeoFireAssistants.updateDriverNearbyLocation(nearbyDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }

      print('Nearby drivers list: ${GeoFireAssistants.nearbyDriversList}');
      setState(() {});
    });
  }

  void createIconMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(1, 1));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/t.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }
}

const colorizeColors = [
  Colors.green,
  Colors.purple,
  Colors.pink,
  Colors.blue,
  Colors.yellow,
  Colors.red,
];

const colorizeTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Pacifico',
);
