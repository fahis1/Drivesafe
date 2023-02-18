import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivesafe/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

void getdata() async {
  // FirebaseFirestore db = FirebaseFirestore.instance;
  // final CollectionReference docRef = db.collection("cameras");
  // QuerySnapshot res = await docRef.get();
  // List<QueryDocumentSnapshot> data = res.docs;
  // print(data.first.data());
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('cameras');
  QuerySnapshot querySnapshot = await _collectionRef.get();

  // Get data from docs and convert map to List
  final allData = querySnapshot.docs.map((doc) => doc.data());
  print(allData.first);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    getdata();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      // home: Container(),
    );
  }
}
