import 'package:elaf/Models/Address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
   Address pickUpLocation = Address();
   Address dropOffLocation = Address();
   void updatePickUpLocationAddress(Address pickUpAddress){
     pickUpLocation = pickUpAddress;
     notifyListeners();
   }
   void updateDropOffLocationAddress(Address dropOffAddress){
     dropOffLocation =dropOffAddress ;
     notifyListeners();
   }
}
