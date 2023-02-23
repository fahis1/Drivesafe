import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'model/user_model.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

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

  LatLng? usercoordinate;

  void placeMarkers() async {
    List<LatLng> alllocations = [];
    // logger.w(allcameras!.length);
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return Center(child: CircularProgressIndicator()); //loading circle
    //   },
    // );
    Location usrlocation = Location(); //getting user location
    LocationData currentLocation = await usrlocation.getLocation();
    usercoordinate =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);
    mp.LatLng usercoordinateasmp =
        mp.LatLng(currentLocation.latitude!, currentLocation.longitude!);
    logger.e(usercoordinate);
    // Navigator.of(context).pop(); //loading end

    // num? distance = mp.SphericalUtil.computeDistanceBetween(
    //     usercoordinateasmp, mp.LatLng(10.211603008889157, 76.19320845015968));
    for (var element in allcameras!) {
      // alllocations.add(LatLng(element.Latitude!, element.Longitude!));
      mp.LatLng camlocation = mp.LatLng(element.latitude!, element.longitude!);
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

    setState(() {});
  }

  String closecamloc = "no location data";
  num? min;
  void findMin(num num, String cl) {
    if (min == null) {
      min = num;
    } else if (min! >= num) {
      min = num;
      closecamloc = cl;
    }
  }

  void findNear() {
    logger.wtf(closestCamera);
    if (closestCamera.isNotEmpty) {
      // double max=0;
      closestCamera.forEach((item) {
        item.forEach((key, value) {
          findMin(value, key);

          // logger.w(key);
          // logger.w(value);
        });
      });
      logger.wtf(closecamloc);
      logger.wtf(min);
    }
  }

  String mapTheme = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();

    mapTheme;
    DefaultAssetBundle.of(context)
        .loadString('assets/mapstyles/dark.json')
        .then((value) {
      mapTheme = value;
    });
  }

  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};
  //   do {

  //  }
  //  while(n>=0);
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
          : GoogleMap(
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
      floatingActionButton: new FloatingActionButton(
        onPressed: findNear,
        tooltip: 'Increment',
        child: new Icon(Icons.replay),
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
