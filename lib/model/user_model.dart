import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Cameras {
  String? camera_type;
  String? place;
  double? latitude;
  double? longitude;
  double? speedlimit;

  Cameras({
    this.latitude,
    this.longitude,
    this.place,
  });
  factory Cameras.fromJson(Map<String, dynamic> parsedJson) {
    return Cameras(
      place: parsedJson['location'].toString(),
      latitude: double.tryParse(parsedJson['latitude'].toString()),
      longitude: double.tryParse(parsedJson['longitude'].toString()),
      // profilepic: parsedJson['profilepic'].toString()
    );
  }
  Map<String, dynamic> toJson() => {
        "place": place,
        "longitude": longitude,
        "latitude": latitude,
        // "profilepic": profilepic,
      };
}
