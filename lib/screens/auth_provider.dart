import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:drivesafe/model/user_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  // FirebaseAuth _fb;
  // AuthProvider(this._fb);
  bool _isLoading = false;

  Stream<User?> stream() => FirebaseAuth.instance.authStateChanges();
  bool get loading => _isLoading;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future signup(String email, String password, String first_name,
      String last_name) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (exception) {
      Fluttertoast.showToast(
        msg: exception.code.toString(),
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      ChatUser newUser = ChatUser(
        user_id: uid,
        email: email,
        first_name: first_name,
        last_name: last_name,

        // profilepic: "",
      );
      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set(newUser.toJson())
            .then((value) {
          Fluttertoast.showToast(
            msg: "Account Created Succesfully",
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
  }

  Future forgetPassword(String email) async {
    var credential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: "Check your email for password reset link",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } on FirebaseAuthException catch (exception) {
      Fluttertoast.showToast(
        msg: exception.code.toString(),
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      _isLoading = false;
      notifyListeners();
      return Future.value('');
    } on FirebaseAuthException catch (ex) {
      _isLoading = false;
      notifyListeners();
      return Future.value(ex.message);
    }
  }
}
