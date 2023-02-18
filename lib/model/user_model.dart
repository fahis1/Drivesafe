import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class cameras {
  String? camera_type;
  String? place;
  double? Latitude;
  double? Longitude;
  double? speedlimit;

  cameras({
    this.Latitude,
    this.Longitude,
    this.place,
  });
  factory cameras.fromJson(Map<String, dynamic> parsedJson) {
    return cameras(
      place: parsedJson['location'].toString(),
      Latitude: double.parse(parsedJson['Latitude'].toString()),
      Longitude: double.parse(parsedJson['Longitude'].toString()),
      // profilepic: parsedJson['profilepic'].toString()
    );
  }
  Map<String, dynamic> toJson() => {
        "place": place,
        "Longitude": Longitude,
        "Latitude": Latitude,
        // "profilepic": profilepic,
      };
}
