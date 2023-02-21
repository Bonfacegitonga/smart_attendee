import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../main.dart';

class AdminSignUpPage extends StatefulWidget {
  final String fName;
  final String lName;
  final String phoneNumber;
  final String email;
  final String password;
  final String role;
  const AdminSignUpPage(
      {super.key,
      required this.fName,
      required this.lName,
      required this.phoneNumber,
      required this.email,
      required this.password,
      required this.role});

  @override
  State<AdminSignUpPage> createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  final formKey = GlobalKey<FormState>();
  final idController = TextEditingController();
  final departmentController = TextEditingController();
  final List<String> _schools = ['admin', 'user'];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedSchool = 'admin';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 50, right: 50, top: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Text(
                "Welcome",
                // style: headingStyle,
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
                    TextFormField(
                      controller: idController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Admin Id",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your Id ' : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedSchool,
                      items: _schools.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSchool = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'School',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Select School';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: departmentController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "DepartMent",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter your Department' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          signUp(
                              widget.email,
                              widget.password,
                              widget.role,
                              widget.fName,
                              widget.lName,
                              widget.phoneNumber,
                              idController.text,
                              _selectedSchool,
                              departmentController.text);
                        },
                        child: const Text("Sign Up")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp(
      String email,
      String password,
      String role,
      String fName,
      String lName,
      String phoneNumber,
      String id,
      String school,
      String department) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFirestore(email, role, fName, lName, phoneNumber,
                    id, school, department)
              })
          .catchError((e) {});
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  postDetailsToFirestore(
      String email,
      String role,
      String firstName,
      String lastName,
      String phoneNumber,
      String id,
      String school,
      String department) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Users');
    ref.doc(user!.uid).set({
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'Id': id,
      'school': school,
      'department': department,
      'classes': [{}]
    });
  }
}
