import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/login_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'model/user_model.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart' as gl;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final logger =
      Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

  List<Cameras>? allcameras;
  late List<Cameras> maincameras = [];
  Cameras? temp1;
  // List<Camerasnear> closestCamera = [];
  List<Closecameras> closestCamera = [];
  Closecameras? mostClosest;
  Location location = Location();
  LatLng? usercoordinate;
  late mp.LatLng usercoordinateasmp;
  // late LocationData currentLocation;
  double? distance;
  late mp.LatLng camlocation;
  late LocationData cLocation;
  String? closecamloc = "loading data";
  String speedMps = '0';
  // String? nextCamera;
  // Camerasnear? nextCamera;

  late int val;
  String? tempmin;
  void getdata() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('cameras');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data());
    allcameras = allData.map((doc) {
      return Cameras.fromJson(doc as Map<String, dynamic>);
    }).toList();

    locRadius();
  }

  void locRadius() async {
    const tenSec = const Duration(seconds: 60);

    cLocation = await location.getLocation();

    usercoordinate = LatLng(cLocation.latitude!, cLocation.longitude!);
    usercoordinateasmp = mp.LatLng(cLocation.latitude!, cLocation.longitude!);
    // Timer.periodic(tenSec, (Timer timer) {
    logger.w(usercoordinateasmp);
    for (var element in allcameras!) {
      camlocation = mp.LatLng(element.latitude!, element.longitude!);
      distance = mp.SphericalUtil.computeDistanceBetween(
              usercoordinateasmp, camlocation)
          .toDouble();

      if (element.latitude != null && distance! <= 20000) {
        addmarker(element.place!, LatLng(element.latitude!, element.longitude!),
            element.place.toString());
        if (element.latitude != null && distance! <= 5000) {
          temp1 = maincameras.firstWhereOrNull((item) => item == element);
          // logger.wtf(temp?.camera!.place);
          // logger.wtf(element.place);
          if (temp == null) {
            maincameras.add(element);
          }
        }
      }
    }

    // logger.wtf(maincameras);
    calculateDistance();
    // });
  }
  // late Location usrlocation;
  // late Location location;

  // void getCurrentLocation() async {}
  Closecameras? temp;
  void calculateDistance() async {
    logger.wtf(maincameras.length);
    // logger.wtf(maincameras!.length);

    location.getLocation().then(
      (location) {
        cLocation = location;
      },
    );

    location.onLocationChanged.listen(
      (newLoc) {
        // logger.w(maincameras);

        cLocation = newLoc;
        // logger.e(newLoc);
        // logger.wtf(cLocation);
        usercoordinate = LatLng(cLocation.latitude!, cLocation.longitude!);
        CameraUpdate.newCameraPosition(
            CameraPosition(target: usercoordinate!, zoom: 12.5));
        usercoordinateasmp =
            mp.LatLng(cLocation.latitude!, cLocation.longitude!);

        Closecameras nearcamera = Closecameras();
        for (var element in maincameras) {
          // logger.wtf(element.place);
          // alllocations.add(LatLng(element.Latitude!, element.Longitude!));
          camlocation = mp.LatLng(element.latitude!, element.longitude!);
          distance = mp.SphericalUtil.computeDistanceBetween(
                  usercoordinateasmp, camlocation)
              .toDouble();

          if (distance! <= 2000) {
            // logger.w(closestCamera.length);
            // logger.i(element.place);
            // if (closestCamera.isNotEmpty) {
            // logger.e(distance);
            temp = closestCamera.firstWhereOrNull(
                (item) => item.camera!.place == element.place);
            // logger.wtf(temp?.camera!.place);
            // logger.wtf(element.place);
            if (temp != null) {
              if (temp?.camera!.place.toString() == element.place.toString()) {
                for (var sa in closestCamera) {
                  // logger.wtf(element.place);
                  // logger.e(distance);
                  if (sa.camera!.place.toString() ==
                      temp?.camera!.place.toString()) {
                    sa.distance = distance;
                  }
                }
              }
            }
            // logger.i(nearcamera.distance);
            // logger.i(nearcamera.camera!.place);
            // logger.e(temp);
            else {
              // for (var sa in closestCamera) {
              //   if (sa.camera!.place.toString() == element.place.toString()) {
              //     for (var sa in closestCamera) {
              //       sa.distance = distance;
              //     }
              //   }
              nearcamera.camera = element;
              nearcamera.distance = distance;
              closestCamera.add(nearcamera);
            }

            // logger.w(distance);
            // logger.w(nearcamera.camera!.place);
            // closestCamera.add(nearcamera);

            // }

            // logger.i(closestCamera.length);
          }

          // if (element.latitude != null && distance! <= 20000) {
          //   addmarker(
          //       element.place!, LatLng(element.latitude!, element.longitude!));
          // }
        }
        // for (var sa in closestCamera) {
        //   logger.i(sa.camera!.place);
        //   logger.i(sa.distance);
        //   logger.i(closestCamera.length);
        // }
        // logger.wtf(closestCamera);
        findNear();
        // });
        setState(() {});
      },
    );
  }

  String? min1;
  int? min2;

  // int? findMin(int num) {
  //   if (min1 == null) {
  //     min1 = num;
  //   } else if (min1! >= num) {
  //     min1 = num;
  //   }
  // }

  findNear() {
    // const tenSec = const Duration(seconds: 3);
    // Timer.periodic(tenSec, (Timer timer) {
    //
    // });
    location.onLocationChanged.listen((newLoc) {
      // final gl.LocationSettings locationSettings = gl.LocationSettings(
      //   accuracy: gl.LocationAccuracy.bestForNavigation,
      //   distanceFilter: 100,
      // );
      // StreamSubscription<gl.Position> positionStream =
      //     gl.Geolocator.getPositionStream(locationSettings: locationSettings)
      //         .listen((gl.Position? position) {});
      // gl.Geolocator.getPositionStream().listen((position) {
      //   var speedinMps = position.speed.toDouble();
      //   speedinMps = speedinMps * 3.6;
      //   speedMps = speedinMps.toStringAsPrecision(2);
      // });
      logger.w(speedMps);
      // This statement will be printed after every one second

      if (closestCamera.isNotEmpty) {
        double min = closestCamera.first.distance!;
        closestCamera.forEach((element) {
          min2 = min.toInt();
          // logger.e(min);
          // logger.wtf(min1);
          closestCamera.forEach((element) {
            if (element.distance! < min) min = element.distance!;

            mostClosest =
                closestCamera.firstWhere((element) => element.distance == min);
          });
        });
        min = min / 1000;
        min1 = min.toStringAsPrecision(2);
        // logger.e(min);

        // logger.w(mostClosest.camera!.place);

        closecamloc = mostClosest?.camera?.place.toString();

        // logger.wtf(mostClosest);
        // logger.wtf(closecamloc);
        // logger.w(value);
        // });
        // });
        // logger.e(closestCamera);
        // logger.wtf(mostClosest);
      }
      // tempmin = min.toString();

      // logger.e(usercoordinate);
      // logger.wtf(min);
      setState(() {});
    });
  }

  loger() {
    for (var element in closestCamera) {
      logger.d(element.camera!.place);
      logger.d(element.distance);
      logger.d(closestCamera.length);
    }
  }

  String mapTheme = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    calculateDistance();
    // placeMarkers();
    findNear();
    // getCurrentLocation();

    mapTheme;
    DefaultAssetBundle.of(context)
        .loadString('assets/mapstyles/dark.json')
        .then((value) {
      mapTheme = value;
    });
  }

  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DriveSafe"),
      ),
      body: usercoordinate == null
          ? Center(
              heightFactor: 100,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("loading location")
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: usercoordinate!,
                    zoom: 12.5,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                    controller.setMapStyle(mapTheme);
                  },
                  markers: _markers.values.toSet(),
                  zoomControlsEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[200],
                          borderRadius: BorderRadius.all(Radius.circular(29))),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Text('$closecamloc' + "   " + '$min1' + " km"),
                      ),
                      height: 100,
                      width: double.infinity,
                    ),
                  ),
                )
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: new FloatingActionButton(
          onPressed: loger,
          tooltip: 'Increment',
          child: new Icon(Icons.replay),
        ),
      ),
    );
  }

  addmarker(String id, LatLng location, String locname) async {
    var markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/cam.png',
    );
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: InfoWindow(title: locname),
      icon: markerIcon,
    );
    _markers[id] = marker;
  }
}
