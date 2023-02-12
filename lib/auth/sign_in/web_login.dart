import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../auth_service.dart';
import '../resetpassword/reset_password.dart';
import '../sign_up/sign_up_screen.dart';

class LoginDesktop extends StatefulWidget {
  //final VoidCallback onClickedSignUp;
  const LoginDesktop({
    super.key,
  });

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  AuthService authService = AuthService();
  bool _obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Image.asset(
          'assets/images/desktopLogin.png',
          fit: BoxFit.cover,
        )),
        Expanded(
            child: Container(
          constraints: const BoxConstraints(maxWidth: 21),
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome back',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account',
                  style: GoogleFonts.inter(
                    fontSize: 23,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 35),
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
                const SizedBox(height: 30),
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
                      validator: (value) => value != null && value.length < 6
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ResetPassword()));
                  },
                  child: const Text(
                    "Forgot password",
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: signIn, child: const Text("login")),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "No account",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: (() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignUpPage()));
                      }),
                      child: const Text('Sign Up',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                    )
                  ],
                )
                // RichText(
                //     text: TextSpan(
                //         style: const TextStyle(color: Colors.black),
                //         text: 'No account?',
                //         children: [
                //       TextSpan(
                //           recognizer: TapGestureRecognizer()
                //             ..onTap = Navigator.of(context).push(
                //                     MaterialPageRoute(
                //                         builder: (context) =>
                //                             const ResetPassword()))
                //                 as GestureTapCallback?,
                //           text: 'Sign up',
                //           style: const TextStyle(
                //               decoration: TextDecoration.underline,
                //               color: Colors.blue))
                //     ]))
              ]),
        ))
      ],
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
