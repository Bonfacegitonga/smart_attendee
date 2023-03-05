import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_attendee/auth/sign_in/login.dart';
import 'package:smart_attendee/auth/sign_up/student_signup.dart';
import 'package:smart_attendee/auth/sign_up/Admin_sign_up.dart';
import 'package:smart_attendee/auth/util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:smart_attendee/screen/student/student_home.dart';

import '../../constant/constant.dart';
import '../../screen/admin/admin_home.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resetpassword/reset_password.dart';

class SignUpPage extends StatefulWidget {
  //final Function() onClickedSignIn;
  const SignUpPage({
    super.key,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final List<String> _roles = ['Student', 'Lecturer'];
  String _selectedRole = 'Student';
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    return Scaffold(
      //appBar: AppBar(backgroundColor: kPrimaryColor,),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Text(
                "WELCOME",
                style: GoogleFonts.inder(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Create New Account",
                      style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: "First Name",
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your first name' : null,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: "Last Name",
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter your last name' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Phone Number",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your phone number' : null,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: _roles.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPassword()));
                          },
                          child: const Text(
                            "Forgot password",
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("Have an account?"),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.blue),
                                ))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        oPrimaryColor)),
                            onPressed: () {
                              final isValid = formKey.currentState!.validate();
                              if (!isValid) return;

                              switch (_selectedRole) {
                                case 'Student':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentSignUP(
                                          fName: firstNameController.text,
                                          lName: lastNameController.text,
                                          phoneNumber: phoneController.text,
                                          email: emailController.text,
                                          password: passwordController.text,
                                          role: _selectedRole),
                                    ),
                                  );
                                  break;
                                case 'Lecturer':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminSignUpPage(
                                          fName: firstNameController.text,
                                          lName: lastNameController.text,
                                          phoneNumber: phoneController.text,
                                          email: emailController.text,
                                          password: passwordController.text,
                                          role: _selectedRole),
                                    ),
                                  );
                                  break;
                              }
                            },
                            child: const Text("NEXT")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp1(String email, String password, String rool, String fName,
      String lName, String phoneNumber) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) =>
              {postDetailsToFirestore(email, rool, fName, lName, phoneNumber)})
          .catchError((e) {});
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  postDetailsToFirestore(String email, String rool, String firstName,
      String lastName, String phoneNumber) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('users');
    ref.doc(user!.uid).set({
      'email': emailController.text,
      'rool': rool,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
    });
  }
}
