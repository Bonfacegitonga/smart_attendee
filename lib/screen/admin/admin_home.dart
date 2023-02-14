import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/auth_service.dart';

import '../../auth/sign_in/login.dart';
import '../../component/container.dart';
import '../../model/user.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AuthService authService = AuthService();
  User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _unitName = TextEditingController();
  final TextEditingController _unitCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var unit = <String, dynamic>{};

  //List<int> _selectedItems = [];
  //final List<int> _selectedIndexes = [];
  //final year = ['1st', '2rd', '3rd', '4th'];

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth >= 600) ? 4 : 2;
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Classes')
                      .where('lecture_id', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    //Map<String, String>? data = snapshot.data!.data()?.cast<String, String>();
                    List<dynamic> classesData =
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return document.data();
                    }).toList();
                    // List<Class> classes = [];
                    // for (int i = 0; i < classesData.length; i++) {
                    //   Map<String, dynamic> classData = classesData[i];
                    //   String course = classData['courseName'];
                    //   String eCode = classData['courseCode'];
                    //   //String classLink = classData['']
                    //   classes.add(Class(courseName: course, courseCode: eCode));
                    // }
                    return Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: classesData.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> classData = classesData[index];
                            String name = classData['unit_name'];
                            return GestureDetector(
                              onTap: () {},
                              child: BeautifulContainer(
                                headline: name,
                                subtitle: "lets fuck",
                              ),
                            );
                          }),
                    );
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createClasses,
          child: const Icon(Icons.add_card),
        ));
  }

  void createClasses() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Form(
              key: _formKey,
              child: Column(children: [
                const Text("Create class"),
                TextFormField(
                  controller: _unitName,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Course title",
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter course title' : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _unitCode,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Course code",
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter course code' : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            unit = {
                              "name": _unitName.text,
                              "code": _unitCode.text
                            };
                          });
                          addClassess(unit, _unitName.text, _unitCode.text);
                          print("object");
                        },
                        child: const Text('Create'))
                  ],
                )
              ]),
            ),
          );
        });
  }

  addClasses(
    Map<String, dynamic> unit,
  ) async {
    var user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance.collection("Users").doc(user!.uid).update({
      "classes": FieldValue.arrayUnion([unit])
    });
  }

  createUnit(String unitName, String code) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Classes');
    ref.add({
      'lecture_id': user!.uid,
      'unit_name': unitName,
      'unit_code': code,
      'student_attendance': [{}]
    });
  }

  void addClassess(
      Map<String, dynamic> unitdetails, String unit, String unitCode) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await addClasses(unitdetails)
          .then((value) => {createUnit(unit, unitCode)})
          .catchError((e) {});
    } on FirebaseException catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    login();
  }

  login() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ));
  }
}



// class ClassList extends StatefulWidget {
//   @override
//   _ClassListState createState() => _ClassListState();
// }

// class _ClassListState extends State<ClassList> {
//   List<Class> classes = [];

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     int crossAxisCount = (screenWidth >= 600) ? 4 : 2;
//     return Container(
//       child: ListView.builder(
//         itemCount: classes.length,
//         itemBuilder: (BuildContext context, int index) {
//           return Container(
//             padding: EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text(
//                   classes[index].name,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
//                 ),
//                 SizedBox(
//                   height: 8.0,
//                 ),
//                 Text(
//                   classes[index].description,
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // void addClass(Class classItem) {
//   //   // setState(() {
//   //   //   classes.add(classItem);
//   //   // });
//     FirebaseDatabase.instance
//         .reference()
//         .child('classes')
//         .push()
//         .set(classItem.toJson());
//   }
// }
