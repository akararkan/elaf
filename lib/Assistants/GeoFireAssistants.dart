import 'package:elaf/Models/NearbyDrivers.dart';

class GeoFireAssistants {

  static List<NearbyDrivers> nearbyDriversList =[];

  static void removeDriverFromList(String key){
    int index = nearbyDriversList.indexWhere((element) => element.key== key);
    nearbyDriversList.removeAt(index);
  }

  static void updateDriverNearbyLocation(NearbyDrivers drivers){
    int index = nearbyDriversList.indexWhere((element) => element.key== drivers.key);
    nearbyDriversList[index].latitude = drivers.latitude;
    nearbyDriversList[index].longitude = drivers.longitude;

  }

}