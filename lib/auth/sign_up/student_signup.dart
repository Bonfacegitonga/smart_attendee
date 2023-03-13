import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/constant.dart';
import '../../main.dart';
import '../../model/course.dart';
import '../util.dart';

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
  Utils err = Utils();
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
  List<String> department = SchoolList.departmentSciencces;
  List<String> courses = SchoolList.coursesSciences;
  FirebaseAuth auth = FirebaseAuth.instance;
  String _selectedSchool = 'School Of Pure, Applied And Health Sciences';
  String _selectedDepartment = 'Department Of Computing & Information Sciences';
  String _selectedCourse = 'Bachelor of Science (Computer Science)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
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
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[200],
                      isExpanded: true,
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
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[200],
                      isExpanded: true,
                      value: SchoolList.schools[0],
                      items: SchoolList.schools.map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSchool = newValue!;
                          if (newValue ==
                              'School Of Pure, Applied And Health Sciences') {
                            department = SchoolList.departmentSciencces;
                            courses = SchoolList.coursesSciences;
                          } else if (newValue ==
                              'School of Arts, Humanities, Social Sciences and Creative Industries') {
                            department = SchoolList.departmentArt;
                            courses = SchoolList.coursesArt;
                          } else if (newValue ==
                              'School Of Business And Economics') {
                            department = SchoolList.departmentBusiness;
                            courses = SchoolList.coursesBussiness;
                          } else if (newValue == 'School Of Education') {
                            department = SchoolList.departmentEducation;
                            courses = SchoolList.coursesEducation;
                          } else if (newValue ==
                              'School Of Natural Resources, Tourism And Hospitality') {
                            department = SchoolList.departmentNaturalResources;
                            courses = SchoolList.coursesNaturalResources;
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
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[200],
                      isExpanded: true,
                      value: courses[0],
                      items: courses.map((String valu) {
                        return DropdownMenuItem<String>(
                          value: valu,
                          child: Text(valu),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCourse = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Select your course';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                                  _selectedCourse,
                                  _selectedYear,
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
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFirestore(email, role, fName, lName, phoneNumber,
                    id, course, year, school, department)
              });
      // .catchError((e) {});
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
      String course,
      String year,
      String school,
      String department) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = auth.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Users');
    ref.doc(user!.uid).set({
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phoneNumber,
      'Id': id,
      'school': school,
      'history': [],
      'department': department,
      'course': course,
    });
  }
}
