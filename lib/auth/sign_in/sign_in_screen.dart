import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/resetpassword/reset_password.dart';
import 'package:smart_attendee/auth/util.dart';

import '../../component/custom_surffix.dart';
import '../../constant/constant.dart';
import '../../main.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const SignInScreen({super.key, required this.onClickedSignUp});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Utils err = Utils();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50, top: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Welcome Back",
                style: headingStyle,
                textAlign: TextAlign.center,
              ),
              const Text(
                "Sign in with your email and password\nor continue with social media",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Form(
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5),
                        labelText: "Email",
                        suffixIcon:
                            CustomSuffixIcon(iconPath: "assets/icons/Mail.svg"),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: passwordController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5),
                        labelText: "Password",
                        suffixIcon:
                            CustomSuffixIcon(iconPath: "assets/icons/Lock.svg"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ResetPassword()));
                      },
                      child: const Text(
                        "Forgot password",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: signIn, child: const Text("login")),
                    const SizedBox(height: 20),
                    RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            text: 'No account?',
                            children: [
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = widget.onClickedSignUp,
                              text: 'Sign up',
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue))
                        ]))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      print(e);
      //err.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
