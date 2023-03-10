import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_attendee/auth/auth_service.dart';
import 'package:smart_attendee/auth/resetpassword/reset_password.dart';
import 'package:smart_attendee/auth/sign_up/sign_up_screen.dart';
import 'package:smart_attendee/auth/util.dart';
import 'package:smart_attendee/constant/constant.dart';
import '../../main.dart';

class SignInScreen extends StatefulWidget {
  // final VoidCallback onClickedSignUp;
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  AuthService authService = AuthService();
  Utils err = Utils();
  bool _obscureText = true;

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
        padding: const EdgeInsets.only(left: 30, right: 30, top: 80),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Text(
                "Welcome Back",
                style: GoogleFonts.inder(
                    color: kPrimaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Sign in with your email and password",
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.email)),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'Enter your email'
                              : null,
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        TextFormField(
                          controller: passwordController,
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: "Password",
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) =>
                              value != null && value.length < 6
                                  ? 'Enter minimum of 6 character'
                                  : null,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: _obscureText
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const ResetPassword()));
                          },
                          child: const Text(
                            "Forgot password? ",
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "No account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const SignUpPage()));
                              },
                              child: const Text('Sign Up',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue)),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 2),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                oPrimaryColor)),
                        onPressed: signIn,
                        child: const Text("LOGIN")),
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
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user found for that email.'),
            duration: Duration(seconds: 5),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Wrong password'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
