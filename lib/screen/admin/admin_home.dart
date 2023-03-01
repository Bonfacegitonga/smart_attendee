import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/auth_service.dart';
import 'package:smart_attendee/constant/constant.dart';
import 'package:smart_attendee/firebase/firebase_service.dart';
import 'package:smart_attendee/model/course.dart';

import '../../auth/sign_in/login.dart';
import '../../component/container.dart';

import '../../component/drawer.dart';
import 'attendance.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('Classes');
  AuthService authService = AuthService();
  User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _unitName = TextEditingController();
  final TextEditingController _unitCode = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  UserService userService = UserService();
  bool isSelectionMode = false;
  List<String> selectedIds = [];
  bool isAllSelected = false;
  bool selectAll = false;
  List? classesData;
  String? fName;
  String? sName;
  String? role;
  //late Function getData;

  @override
  void initState() {
    super.initState();
    getUser();
    //initializeSelection();
  }

  Future<void> deleteDocuments() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (String id in selectedIds) {
      batch.delete(collectionRef.doc(id));
    }

    await batch.commit();
    isSelectionMode = false;
  }

  Future getUser() async {
    User user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    if (documentSnapshot.exists) {
      setState(() {
        fName = documentSnapshot.get('last_name');
        sName = documentSnapshot.get('first_name');
        role = documentSnapshot.get('role');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth >= 600) ? 4 : 2;
    final email = user.email;
    final String myrole = role.toString();
    final String fullNames = '$fName $sName ($myrole)';

    return Scaffold(
        drawer: MyDrawer(
          names: fullNames.toUpperCase(),
          email: email.toString(),
          signOut: logout,
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("Class Dashboard"),
          actions: [
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  userService.deleteDocuments(selectedIds, isSelectionMode);
                },
              ),
            if (isSelectionMode)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSelectionMode = false;
                    isAllSelected = false;
                    selectedIds.clear();
                  });
                  // initializeSelection();
                },
              )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                  visible: isSelectionMode,
                  child: isAllSelected
                      ? TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blue)),
                          child: const Text(
                            'Unselect all',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              isAllSelected = false;
                              isSelectionMode = false;
                              selectedIds.clear();
                            });
                          },
                        )
                      : TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blue)),
                          child: const Text(
                            'Select all',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              isAllSelected = true;
                              selectedIds = classesData!
                                  .map<String>((classData) => classData['id'])
                                  .toList();
                            });
                          },
                        )),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Classes')
                      .where('lecture_id', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No classes created yet!"),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Something went wrong!",
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    classesData =
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String id = document.id;
                      return {'id': id, ...data};
                    }).toList();

                    return Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: classesData!.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> classData =
                                classesData![index];
                            String name = classData['unit_name'];
                            String code = classData['unit_code'];
                            String id = classData['id'];
                            List<dynamic>? attendanceHistory =
                                classData['student_attendance'];
                            bool isSelected = selectedIds.contains(id);

                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  isSelectionMode = true;
                                  if (isSelected) {
                                    selectedIds.remove(id);
                                  } else {
                                    selectedIds.add(id);
                                  }
                                });
                              },
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AttendanceHistory(
                                              attendanceHistory:
                                                  attendanceHistory ?? [],
                                              title: name,
                                              documentLink: id,
                                              cName: name,
                                              cCode: code,
                                            )));
                              },
                              child: BeautifulContainer(
                                headline: name,
                                subtitle: code,
                                kcolor: selectedIds.contains(id)
                                    ? primaryColor
                                    : selectedColor,
                              ),
                            );
                          }),
                    );
                  }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: createClasses,
          child: const Icon(Icons.add_card),
        ));
  }

  void createClasses() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 230,
              child: Form(
                key: _formKey,
                child: (Column(children: [
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
                            // setState(() {
                            //   unit = {
                            //     "name": _unitName.text,
                            //     "code": _unitCode.text
                            //   };
                            // });
                            addClassess(_unitName.text.toUpperCase(),
                                _unitCode.text.toUpperCase());
                          },
                          child: const Text('Create'))
                    ],
                  )
                ])),
              ),
            ),
          );
        });
  }

  // final addStudent = {
  //   "Names": "Wanjiku Bonface Gitonga",
  //   "reg_no": "SB06/SR/MN/9877/2019",
  //   "time": DateTime.now()
  // };

  // addClasses() async {
  //   var user = FirebaseAuth.instance.currentUser;
  //   FirebaseFirestore.instance.collection("Classes").doc(document).update({
  //     "classes": FieldValue.arrayUnion([addStudent])
  //   });
  // }

  createUnit(String unitName, String code) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Classes');
    ref.add({
      'lecture_id': user!.uid,
      'unit_name': unitName,
      'unit_code': code,
    });
  }

  void addClassess(String unit, String unitCode) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await createUnit(unit, unitCode).catchError((e) {});
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
