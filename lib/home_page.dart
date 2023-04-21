import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'model/user_model.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final logger =
      Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

  List<Cameras>? allcameras;
  List<Map<String, num>> closestCamera = [];
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
    placeMarkers();
  }

  // late Location usrlocation;
  // late Location location;
  Location location = Location();
  LatLng? usercoordinate;
  late mp.LatLng usercoordinateasmp;
  // late LocationData currentLocation;
  late mp.LatLng camlocation;
  late LocationData cLocation;
  // void getCurrentLocation() async {}

  void placeMarkers() async {
    List<LatLng> alllocations = [];
    logger.wtf(allcameras!.length);

    // num? distance = mp.SphericalUtil.computeDistanceBetween(
    //     usercoordinateasmp, mp.LatLng(10.211603008889157, 76.19320845015968));

    //usrlocation = Location(); //getting user location

    // const tenSec = const Duration(seconds: 3);
    // Timer.periodic(tenSec, (Timer timer) async {

    // currentLocation = await usrlocation.getLocation();
    // usercoordinate =
    //     LatLng(currentLocation.latitude!, currentLocation.longitude!);
    // usercoordinateasmp =
    //     mp.LatLng(currentLocation.latitude!, currentLocation.longitude!);

    // logger.e(usercoordinate);

    location.getLocation().then(
      (location) {
        cLocation = location;
      },
    );

    location.onLocationChanged.listen(
      (newLoc) {
        cLocation = newLoc;
        // logger.e(newLoc);
        // logger.wtf(cLocation);
        usercoordinate = LatLng(cLocation.latitude!, cLocation.longitude!);
        usercoordinateasmp =
            mp.LatLng(cLocation.latitude!, cLocation.longitude!);

        logger.w(usercoordinateasmp);
        for (var element in allcameras!) {
          // alllocations.add(LatLng(element.Latitude!, element.Longitude!));
          camlocation = mp.LatLng(element.latitude!, element.longitude!);
          num? distance = mp.SphericalUtil.computeDistanceBetween(
              usercoordinateasmp, camlocation);

          if (distance <= 12000) {
            closestCamera.add({element.place!: distance});
          }
          if (element.latitude != null && distance <= 20000) {
            addmarker(
                element.place!, LatLng(element.latitude!, element.longitude!));
          }
        }
        // });

        setState(() {});
      },
    );
  }

  String closecamloc = "no location data";
  int? min;

  void findMin(int num, String cl) {
    if (min == null) {
      min = num;
    } else if (min! >= num) {
      min = num;
      closecamloc = cl;
    }
  }

  findNear() {
    // const tenSec = const Duration(seconds: 3);

    // Timer.periodic(tenSec, (Timer timer) {

    location.onLocationChanged.listen((newLoc) {
      // This statement will be printed after every one second

      if (closestCamera.isNotEmpty) {
        // double max=0;
        closestCamera.forEach((item) {
          item.forEach((key, value) {
            val = value.toInt();
            findMin(val, key);

            // logger.w(key);
            // logger.w(value);
          });
        });
      }
      // tempmin = min.toString();
      logger.wtf(closecamloc);
      logger.e(usercoordinate);
      logger.wtf(min);
      setState(() {});
      // });
    });
  }

  String mapTheme = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    placeMarkers();
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
                        child: Text('$closecamloc' + "   " + '$min'),
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
          onPressed: findNear,
          tooltip: 'Increment',
          child: new Icon(Icons.replay),
        ),
      ),
    );
  }

  addmarker(String id, LatLng location) async {
    var markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/cam.png',
    );
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      icon: markerIcon,
    );
    _markers[id] = marker;
  }
}
