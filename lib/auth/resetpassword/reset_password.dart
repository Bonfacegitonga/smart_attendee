import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_attendee/constant/constant.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  //Utils err = Utils();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //padding: const EdgeInsets.only(left: 30, right: 30, top: 80),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      "Enter your email, \nTo recieve an email to reset your password.",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(7),
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) =>
                          email != null && !EmailValidator.validate(email)
                              ? 'Enter your email'
                              : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                oPrimaryColor)),
                        onPressed: sendEmail,
                        child: const Text("Reset Password")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future sendEmail() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      print(e);
      //err.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
