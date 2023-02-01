import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../main.dart';

class StudentSignUP extends StatefulWidget {
  final String fName;
  final String lName;
  final String phoneNumber;
  final String email;
  final String password;
  final String role;
  const StudentSignUP(
      {super.key,
      required this.fName,
      required this.lName,
      required this.phoneNumber,
      required this.email,
      required this.password,
      required this.role});

  @override
  State<StudentSignUP> createState() => _StudentSignUPState();
}

class _StudentSignUPState extends State<StudentSignUP> {
  final formKey = GlobalKey<FormState>();
  final idController = TextEditingController();
  final courseTitle = TextEditingController();
  final departmentController = TextEditingController();
  final List<String> year = [
    '1.1',
    '1.2',
    '2.1',
    '2.2',
    '3.1',
    '3.2',
    '4.1',
    '4.2'
  ];
  String _selectedYear = '1.1';
  final List<String> _schools = [
    'School of Sciences',
    'School of Art',
    'School of Education',
    'School of Bussiness'
  ];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedSchool = 'School of Sciences';
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
                    TextFormField(
                      controller: idController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: "Registration Number",
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value!.isEmpty
                          ? 'Enter your Registration number '
                          : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: courseTitle,
                            cursorColor: Colors.black,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelText: "Course Title",
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value!.isEmpty ? 'Course Undertaken?' : null,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedYear,
                            items: year.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedYear = newValue!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Academic year',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Select academic year';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
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
                              courseTitle.text,
                              _selectedYear,
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
      String course,
      String year,
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
                    id, course, year, school, department)
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
      String course,
      String year,
      String school,
      String department) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Students');
    ref.doc(user!.uid).set({
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'Id': id,
      'school': school,
      'department': department
    });
  }
}
