class DirectionDetails {
  int distanceValue =0;
  int durationValue =0;
  String distanceText ="";

  String? durationText;

  String encodedPoints = " ";

  DirectionDetails();

  DirectionDetails.allFields(
      {required this.distanceValue,
      required this.durationValue,
      required this.distanceText,
      required this.durationText,
      required this.encodedPoints});
}
