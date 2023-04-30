import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';

class Passreset extends StatefulWidget {
  static const String routeName = 'pass';
  const Passreset({super.key});

  @override
  State<Passreset> createState() => _PassresetState();
}

class _PassresetState extends State<Passreset> {
  TextEditingController emailcontroller = TextEditingController();
  AuthProvider authService = AuthProvider();
  bool isClicked = false;
  bool _loader = false;
  Future<void> checkValues() async {
    setState(() {
      isClicked = true;
    });
    String email = emailcontroller.text.trim();
    if (email == "") {
      Fluttertoast.showToast(
        msg: "Please Fill all fields!!!",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else if (!EmailValidator.validate(email)) {
      Fluttertoast.showToast(
        msg: "Invalid Email Address!",
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      setState(() {
        _loader = true;
      });
      await authService.forgetPassword(email);
      popnow();
      setState(() {
        _loader = false;
      });
    }
  }

  void popnow() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailcontroller.dispose();
    super.dispose();
  }

  chageObscured() {
    setState(() {
      isObscured = !isObscured;
      obscured = !obscured;
    });
  }

  bool obscured = true;
  bool isObscured = true;
  @override
  Widget build(BuildContext context) {
    IconData? icon;
    const _clrText = Color(0xff707070);
    final _cx = MediaQuery.of(context).size.width;
    Function()? notifyParentIconCLicl;
    final authProvider = context.watch<AuthProvider>();
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/driving.svg",
                    width: 98,
                    height: 98,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "DriveSafe",
                    style: TextStyle(
                        color: _clrText,
                        fontSize: 36,
                        fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    "Password Reset",
                    style: TextStyle(
                      color: _clrText,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: emailcontroller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text("E-mail")),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  if (authProvider.loading)
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  if (!authProvider.loading)
                    SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0)),
                            onPressed: checkValues,
                            child: const Text("Reset password by email"))),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: (_cx / 2) - 40, child: const Divider()),
                      SizedBox(width: (_cx / 2) - 40, child: const Divider()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Sign in with Google
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
