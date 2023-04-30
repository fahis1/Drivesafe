import 'package:drivesafe/model/user_model.dart';
import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/login_form.dart';
import 'package:drivesafe/screens/login_form.dart';
import 'package:drivesafe/screens/register_form.dart';
import 'package:drivesafe/screens/passreset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivesafe/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:logger/logger.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        StreamProvider(
            create: (context) => context.watch<AuthProvider>().stream(),
            initialData: null)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        //home: const LoginForm(),
        home: const HomePage(),
        routes: {
          RegisterForm.routeName: (context) => const RegisterForm(),
          LoginForm.routeName: (context) => const LoginForm(),
          Passreset.routeName: (context) => const Passreset(),
          // ForgetPasswordScreen.routeName: (context) =>
          //     const ForgetPasswordScreen(),
          HomePage.routeName: (context) => const HomePage(),
        },

        // home: Container(),
      ),
    );
  }
}
