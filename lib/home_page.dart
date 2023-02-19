import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'model/user_model.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  final logger =
      Logger(printer: PrettyPrinter(colors: true, printEmojis: true));
  final LatLng CurrentLocation = LatLng(10.211603008889157, 76.19320845015968);
  List<Cameras>? allcameras;
  void getdata() async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('cameras');
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data());
    allcameras = allData.map((doc) {
      return Cameras.fromJson(doc as Map<String, dynamic>);
    }).toList();
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

  void _incrementCounter() async {
    // List<LatLng> alllocations = [];
    // logger.w(allcameras!.length);
    for (var element in allcameras!) {
      // alllocations.add(LatLng(element.Latitude!, element.Longitude!));
      if (element.latitude != null) {
        addmarker(
            element.place!, LatLng(element.latitude!, element.longitude!));
      }
    }

    print(allcameras!.length);
    Location usrlocation = Location();
    LocationData currentLocation = await usrlocation.getLocation();
    LatLng usercoordinate =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DriveSafe"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: CurrentLocation,
          zoom: 7.5,
        ),
        onMapCreated: (controller) {
          mapController = controller;
          controller.setMapStyle(mapTheme);
        },
        markers: _markers.values.toSet(),
        zoomControlsEnabled: false,
        myLocationEnabled: true,
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
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
