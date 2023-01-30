import 'dart:html';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/util.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_attendee/student/student_home.dart';

import '../../admin/admin_home.dart';
import '../../component/custom_surffix.dart';
import '../../constant/constant.dart';
import '../../main.dart';

class SignUpPage extends StatefulWidget {
  final Function() onClickedSignIn;
  const SignUpPage({super.key, required this.onClickedSignIn});

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
  final List<String> _roles = ['admin', 'user'];
  String _selectedRole = 'admin';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50, top: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Welcome",
                style: headingStyle,
                textAlign: TextAlign.center,
              ),
              const Text(
                "Create New Account\nor continue with social media",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: firstNameController,
                    //         cursorColor: Colors.black,
                    //         textInputAction: TextInputAction.next,
                    //         decoration: InputDecoration(
                    //           contentPadding: const EdgeInsets.all(10),
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           labelText: "First Name",
                    //         ),
                    //         autovalidateMode:
                    //             AutovalidateMode.onUserInteraction,
                    //         validator: (value) =>
                    //             value!.isEmpty ? 'Enter your first name' : null,
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 10,
                    //     ),
                    //     Expanded(
                    //       child: TextFormField(
                    //         controller: lastNameController,
                    //         cursorColor: Colors.black,
                    //         textInputAction: TextInputAction.next,
                    //         decoration: InputDecoration(
                    //           contentPadding: const EdgeInsets.all(10),
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(10),
                    //           ),
                    //           labelText: "Last Name",
                    //         ),
                    //         autovalidateMode:
                    //             AutovalidateMode.onUserInteraction,
                    //         validator: (value) =>
                    //             value!.isEmpty ? 'Enter your last name' : null,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                    // TextFormField(
                    //   controller: phoneController,
                    //   keyboardType: TextInputType.phone,
                    //   cursorColor: Colors.black,
                    //   textInputAction: TextInputAction.next,
                    //   decoration: InputDecoration(
                    //     contentPadding: const EdgeInsets.all(10),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     labelText: "Phone Number",
                    //   ),
                    //   autovalidateMode: AutovalidateMode.onUserInteraction,
                    //   validator: (value) =>
                    //       value!.isEmpty ? 'Enter your phone number' : null,
                    // ),
                    // const SizedBox(height: 20),
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
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot password",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          signUp1(emailController.text, passwordController.text,
                              _selectedRole);
                        },
                        child: const Text("Sign Up")),
                    const SizedBox(height: 20),
                    RichText(
                        text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            text: 'Already have account? ',
                            children: [
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = widget.onClickedSignIn,
                              text: 'Login',
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

  void signUp1(String email, String password, String rool) async {
    if (formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(email, rool)})
          .catchError((e) {});
    }
  }

  postDetailsToFirestore(String email, String rool) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('users');
    ref.doc(user!.uid).set({'email': emailController.text, 'rool': rool});
  }

  // Future signUp() async {
  //   final isValid = formKey.currentState!.validate();
  //   if (!isValid) return;
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(
  //             child: CircularProgressIndicator(),
  //           ));
  //   try {
  //     FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //     //create custom claim
  //     Map<String, dynamic> customClaims = {
  //       'role': _selectedRole,
  //     };

  //     //set custom claim
  //     //await FirebaseAuth.instance.setCustomUserClaims(user.uid, customClaims);

  //     // await FirebaseFirestore.instance.collection('users').add({
  //     //   'email': emailController,
  //     //   'first_name': firstNameController,
  //     //   'last_name': lastNameController,
  //     //   'phone': phoneController,
  //     //   'role': _selectedRole,
  //     // });

  //     // .then((value) {
  //     //   if (_selectedRole == 'admin') {
  //     //     Navigator.of(context).push(
  //     //         MaterialPageRoute(builder: (context) => const AdminHomePage()));
  //     //   } else {
  //     //     Navigator.of(context).push(
  //     //         MaterialPageRoute(builder: (context) => const StudentHomePage()));
  //     //   }
  //     // });
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //     //err.showSnackBar(e.message);
  //   }
  //   navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }
}
