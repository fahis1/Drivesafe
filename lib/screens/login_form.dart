import 'package:drivesafe/screens/auth_provider.dart';
import 'package:drivesafe/screens/passreset.dart';
import 'package:drivesafe/screens/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:drivesafe/screens/login_form.dart';

class LoginForm extends StatefulWidget {
  static const String routeName = 'log_screen';
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _email = TextEditingController(),
      _pass = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void signIn(AuthProvider provider) async {
    final msg = await provider.signIn(_email.text, _pass.text);
    if (msg == '') return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                    "Login",
                    style: TextStyle(
                      color: _clrText,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), label: Text("E-mail")),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _pass,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RegisterForm.routeName);
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: _clrText, fontSize: 14),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Passreset.routeName);
                          },
                          child: const Text(
                            "Forgot password ?",
                            style: TextStyle(color: _clrText, fontSize: 14),
                          )),
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
                            onPressed: () => signIn(authProvider),
                            child: const Text("Sign in"))),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: (_cx / 2) - 40, child: const Divider()),
                      const Text(
                        "Or",
                        style: TextStyle(color: _clrText),
                      ),
                      SizedBox(width: (_cx / 2) - 40, child: const Divider()),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Sign in with Google
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: (_cx / 2) - 20,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xffe4e7ea))),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/google.svg",
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Sign in with Google",
                                    style: TextStyle(color: _clrText),
                                  )
                                ],
                              ),
                            )),
                      ),
                      //Sign in with apple
                      SizedBox(
                        width: (_cx / 2) - 25,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff000000))),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  SvgPicture.asset("assets/svg/apple.svg"),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Sign in with Apple",
                                    style: TextStyle(color: _clrText),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ],
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
