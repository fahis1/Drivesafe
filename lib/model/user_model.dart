import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Cameras {
  String? camera_type;
  String? place;
  double? latitude;
  double? longitude;
  double? speedlimit;

  Cameras({
    this.camera_type,
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
        "location": place,
        "longitude": longitude,
        "latitude": latitude,
        "cameraType": camera_type,
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

class ChatUser {
  String? first_name;
  String? last_name;
  String? user_id;
  String? email;

  ChatUser({
    this.email,
    this.user_id,
    this.first_name,
    this.last_name,
  });
  factory ChatUser.fromJson(Map<String, dynamic> parsedJson) {
    return ChatUser(
      user_id: parsedJson['user_id'].toString(),
      first_name: parsedJson['first_name'].toString(),
      last_name: parsedJson['last_name'].toString(),
      email: parsedJson['email'].toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        "user_id": user_id,
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
      };
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
