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

class Closecameras {
  double? distance;
  Cameras? camera;
  Closecameras({this.camera, this.distance});
  // factory Cameras.fromJson(Map<String, dynamic> parsedJson) {
  //   return Cameras(
  //     place: parsedJson['location'].toString(),
  //     latitude: double.tryParse(parsedJson['latitude'].toString()),
  //     longitude: double.tryParse(parsedJson['longitude'].toString()),
  //     // profilepic: parsedJson['profilepic'].toString()
  //   );
  // }
  // Map<String, dynamic> toJson() => {
  //       "place": place,
  //       "longitude": longitude,
  //       "latitude": latitude,
  //       // "profilepic": profilepic,
  //     };
}
// class Camerasnear {
//   String? place;
//   num? distance;

//   Camerasnear(this.place, this.distance);

//   factory Camerasnear.fromJson(dynamic json) {
//     return Camerasnear(json['place'] as String, json['distance'] as num);
//   }

//   @override
//   String toString() {
//     return '{ ${this.place}, ${this.distance} }';
//   }
// }
