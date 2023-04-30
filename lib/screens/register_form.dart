import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';

class RegisterForm extends StatefulWidget {
  static const String routeName = 'reg_screen';
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<RegisterForm> {
  final TextEditingController _email = TextEditingController(),
      _pass = TextEditingController();

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController fnamecontroller = TextEditingController();
  TextEditingController lnamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _loader = false;
  bool isClicked = false;
  AuthProvider authService = AuthProvider();
  Future<void> checkValues() async {
    setState(() {
      isClicked = true;
    });
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    String first_name = fnamecontroller.text.trim();
    String last_name = lnamecontroller.text.trim();
    if (first_name == "" || last_name == "" || password == "" || email == "") {
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
      await authService.signup(
        email,
        password,
        first_name,
        last_name,
      );
      popnow();
      setState(() {
        _loader = false;
      });
    }
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
  void popnow() {
    Navigator.pop(context);
  }

  void dispose() {
    // TODO: implement dispose
    emailcontroller.dispose();
    passwordcontroller.dispose();
    fnamecontroller.dispose();
    lnamecontroller.dispose();
    super.dispose();
    // Navigator.popAndPushNamed(context, LoginForm.routeName);
  }

  void signIn(AuthProvider provider) async {
    final msg = await provider.signIn(_email.text, _pass.text);
    if (msg == '') return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    const _clrText = Color(0xff707070);
    final _cx = MediaQuery.of(context).size.width;
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
                    height: 10,
                  ),
                  const Text(
                    "DriveSafe",
                    style: TextStyle(
                        color: _clrText,
                        fontSize: 36,
                        fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      color: _clrText,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailcontroller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text("E-mail")),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: fnamecontroller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("First name")),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: lnamecontroller,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text("Last name")),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  TextField(
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Password"),
                      suffixIcon: InkWell(
                        onTap: chageObscured,
                        child: Icon(
                          isObscured
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 27,
                          color: Colors.blue.shade200,
                        ),
                      ),
                    ),
                    // obscured: isObscured,
                    // notifyParentIconCLicl: chageObscured,

                    obscureText: obscured,
                  ),
                  // TextField(
                  //   controller: _pass,
                  //   decoration: const InputDecoration(
                  //       border: OutlineInputBorder(), label: Text("Password")),
                  // ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // TextButton(
                      //     onPressed: () {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => const LoginForm()),
                      //       );
                      //     },
                      //     child: const Text(
                      //       "login",
                      //       style: TextStyle(color: _clrText, fontSize: 14),
                      //     )),
                      // TextButton(
                      //     onPressed: () {},
                      //     child: const Text(
                      //       "Forgot password ?",
                      //       style: TextStyle(color: _clrText, fontSize: 14),
                      //     )),
                    ],
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
                            child: const Text("Sign up"))),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
