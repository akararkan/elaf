import 'package:elaf/Models/Address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  late Address pickUpLocation = Address();
  void updatePickUpLocationAddress(Address pickUpAddress){
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }
}