import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/user_model.dart';

const LatLng CurrentLocation = LatLng(10.011603008889157, 76.29320845015968);

// class update_cameras {
//   Future update(String email, String password) async {
//     CollectionReference _collectionRef =
//         FirebaseFirestore.instance.collection('collection');
//     QuerySnapshot querySnapshot = await _collectionRef.get();

//     // Get data from docs and convert map to List
//     final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
//     print(allData);
//     // DocumentSnapshot userData =
//     // await FirebaseFirestore.instance.collection("cameras").doc().get();
//     // cameras loginUser =
//     // cameras.fromJson(userData.data() as Map<String, dynamic>);
//     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     // prefs.setString("email", loginUser.email.toString());
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  Map<String, Marker> _markers = {};
  void _incrementCounter() {
    setState(() {
      addmarker('test', CurrentLocation);
    });
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
        },
        markers: _markers.values.toSet(),
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
    setState(() {});
  }
}
