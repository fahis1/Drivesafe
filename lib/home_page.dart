import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/login_form.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart' as log;
import 'model/user_model.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
// import 'package:geolocator/geolocator.dart' as gl;

class HomePage extends StatefulWidget {
  static const String routeName = 'home_page';
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final logger =
      log.Logger(printer: log.PrettyPrinter(colors: true, printEmojis: true));

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
  int count = 0;
  bool isopen = false;
  bool isclosed = false;
  bool iskilled = false;
  var uuid = Uuid();
  final player = AudioCache();
  static AudioPlayer? instance;
  final TextEditingController _place = TextEditingController(),
      _type = TextEditingController();
  // String? nextCamera;
  // Camerasnear? nextCamera;
  void initaudio() async {
    instance = await player.loop("sounds/beep.mp3");
    // player.loop('sounds/beep.mp3');
    // instance = await player.loop("bgmusic.mp3");
  }

  void stopaudio() async {
    if (instance != null) {
      instance!.pause();
    }
  }

  late int val;
  String? tempmin;
  void getdata() async {
    logger.i('getdata started');
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('cameras');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data());
    allcameras = allData.map((doc) {
      return Cameras.fromJson(doc as Map<String, dynamic>);
    }).toList();
    logger.i('getdata terminated');

    locRadius();
  }

  void locRadius() async {
    logger.i('locradius started');

    const tenSec = const Duration(seconds: 60);

    cLocation = await location.getLocation();

    usercoordinate = LatLng(cLocation.latitude!, cLocation.longitude!);
    usercoordinateasmp = mp.LatLng(cLocation.latitude!, cLocation.longitude!);
    // Timer.periodic(tenSec, (Timer timer) {
    logger.w(usercoordinate);
    for (var element in allcameras!) {
      camlocation = mp.LatLng(element.latitude!, element.longitude!);
      distance = mp.SphericalUtil.computeDistanceBetween(
              usercoordinateasmp, camlocation)
          .toDouble();

      if (element.latitude != null && distance! <= 20000) {
        addmarker(element.place!, LatLng(element.latitude!, element.longitude!),
            element.place.toString());
        if (element.latitude != null && distance! <= 10000) {
          temp1 = maincameras.firstWhereOrNull((item) => item == element);
          // logger.wtf(temp?.camera!.place);
          // logger.wtf(element.place);
          if (temp == null) {
            maincameras.add(element);
          }
        }
      }
    }
    logger.i('locradius terminated');

    // logger.wtf(maincameras);
    // calculateDistance();
    // });
    setState(() {});
  }
  // late Location usrlocation;
  // late Location location;

  // void getCurrentLocation() async {}
  Closecameras? temp;
  void calculateDistance() async {
    // logger.wtf(maincameras.length);
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
        // CameraUpdate.newCameraPosition(
        //     CameraPosition(target: usercoordinate!, zoom: 12.5));

        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(usercoordinate!, 12.5));

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

          if (distance! <= 10000) {
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
  int? min3;

  // int? findMin(int num) {
  //   if (min1 == null) {
  //     min1 = num;
  //   } else if (min1! >= num) {
  //     min1 = num;
  //   }
  // }
  void addtomap(double lat, double long) async {
    double ulat = lat;
    double ulong = long;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      // width: 60,
      padding: EdgeInsets.all(18),
      body: Column(
        children: [
          const Text(
            "Add new camera here",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          TextField(
            controller: _place,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Camera Location name")),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _type,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), label: Text("Camera type")),
          ),
        ],
      ),
      // showCloseIcon: true,

      btnOkText: "Add Camera",
      btnOkColor: Colors.blue.shade300,
      btnOkIcon: Icons.add_circle_outline,
      btnOkOnPress: () {
        faddcams(_place.text, _type.text, ulat, ulong);
      },
      // autoDismiss: true,

      // autoHide: const Duration(seconds: 3),
      onDismissCallback: (type) {
        isclosed = true;
      },
    ).show();
  }

  faddcams(String pl, String ct, double lat, double long) async {
    String cplace = pl;
    String ctype = ct;
    double ulat = lat;
    double ulong = long;
    Cameras newCam = Cameras(
      camera_type: ctype,
      longitude: ulong,
      latitude: ulat,
      place: cplace,
    );
    String uid = uuid.v1();
    logger.i(uid);
    try {
      await FirebaseFirestore.instance
          .collection("cameras")
          .doc(uid)
          .set(newCam.toJson())
          .then((value) {
        Fluttertoast.showToast(
          msg: "camera added Succesfully",
          backgroundColor: Colors.black,
          textColor: Colors.white,
        );
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

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
      // logger.w(speedMps);
      // This statement will be printed after every one second

      if (closestCamera.isNotEmpty) {
        double min = closestCamera.first.distance!;
        closestCamera.forEach((element) {
          min2 = min.toInt();
          min3 = min.toInt();
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
      if (min3! <= 600 && count == 0) {
        isclosed = false;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          // showCloseIcon: true,
          title: "Alert",
          desc: "Camera detected within 600 meters",
          btnCancelText: "Ok",
          btnCancelOnPress: () {
            if (instance != null) {
              instance!.pause();
            }
            iskilled = true;
            isopen = false;
          },
          // autoDismiss: true,

          // autoHide: const Duration(seconds: 3),
          onDismissCallback: (type) {
            isclosed = true;
          },
        ).show();
        initaudio();
        count = 1;
      }
      if (min3! >= 600 && count == 1) {
        if (isclosed != true) {
          AwesomeDialog(context: context).dismiss();
        }
        count = 0;
        stopaudio();
      }
      setState(() {});
    });
  }

  loger() {
    getdata();
    // for (var element in closestCamera) {
    //   logger.d(element.camera!.place);
    //   logger.d(element.distance);
    //   logger.d(closestCamera.length);
    // }
  }

  String mapTheme = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initaudio();
    getdata();
    // calculateDistance();
    // placeMarkers();
    // findNear();
    // getCurrentLocation();

    mapTheme;
    DefaultAssetBundle.of(context)
        .loadString('assets/mapstyles/dark.json')
        .then((value) {
      mapTheme = value;
    });
  }

//  => context.read<AuthProvider>().signOut()
  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: context.watch<AuthProvider>().stream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoginForm();
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  tooltip: 'Logout',
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.scale,
                      showCloseIcon: true,
                      title: "Logout",
                      desc: "Are you sure ?",
                      btnOkText: "yes",
                      btnCancelOnPress: () {},
                      btnOkOnPress: () =>
                          context.read<AuthProvider>().signOut(),
                    ).show();
                  },
                  icon: const Icon(Icons.logout),
                  splashRadius: 20,
                )
              ],
              title: const Text("DriveSafe"),
            ),
            body: usercoordinate == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: Center(
                            child: AnimatedTextKit(
                              animatedTexts: [
                                WavyAnimatedText("Please wait...",
                                    speed: const Duration(milliseconds: 500))
                              ],
                            ),
                          ),
                        )
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
                          calculateDistance();
                        },

                        markers: _markers.values.toSet(),
                        zoomControlsEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationEnabled: true,
                        // myLocationButtonEnabled: true,
                        onLongPress: (LatLng latLng) {
                          double ulat = latLng.latitude;
                          double ulong = latLng.longitude;
                          addtomap(ulat, ulong);
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(13),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color:
                                        const Color.fromARGB(255, 245, 34, 34)),
                                color: const Color.fromARGB(255, 253, 130, 128),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(25))),
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  "Place: " '$closecamloc' +
                                      "\n" +
                                      "Distance: " '$min1 km',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            height: 90,
                            width: double.infinity,
                          ),
                        ),
                      )
                    ],
                  ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                onPressed: locRadius,
                tooltip: 'Refresh',
                child: const Icon(Icons.replay),
              ),
            ),
          );
        });
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
