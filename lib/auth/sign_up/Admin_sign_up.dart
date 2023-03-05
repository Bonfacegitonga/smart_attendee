import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_attendee/model/course.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedSchool = 'School Of Pure, Applied And Health Sciences';
  String _selectedDepartment = 'Department Of Computing & Information Sciences';
  List<String> department = SchoolList.departmentSciencces;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),
              Text(
                "Create New Account",
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Fill in the form",
                    style: GoogleFonts.inter(
                        color: kPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ],
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
                      isExpanded: true,
                      value: SchoolList.schools[0],
                      items: SchoolList.schools.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSchool = newValue!;
                          if (newValue ==
                              'School Of Pure, Applied And Health Sciences') {
                            department = SchoolList.departmentSciencces;
                          } else if (newValue ==
                              'School of Arts, Humanities, Social Sciences and Creative Industries') {
                            department = SchoolList.departmentArt;
                          } else if (newValue ==
                              'School Of Business And Economics') {
                            department = SchoolList.departmentBusiness;
                          } else if (newValue == 'School Of Education') {
                            department = SchoolList.departmentEducation;
                          } else if (newValue ==
                              'School Of Natural Resources, Tourism And Hospitality') {
                            department = SchoolList.departmentNaturalResources;
                          }
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
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[200],
                      isExpanded: true,
                      value: department[0],
                      items: department.map((String alue) {
                        return DropdownMenuItem<String>(
                          value: alue,
                          child: Text(alue),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDepartment = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Select your department';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        oPrimaryColor)),
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
                                  _selectedDepartment);
                            },
                            child: const Text("Sign Up")),
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
              });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('The account already exists for that email.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
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
