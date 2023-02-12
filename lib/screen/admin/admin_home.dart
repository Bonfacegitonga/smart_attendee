import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/auth_service.dart';

import '../../auth/sign_in/login.dart';
import '../../component/selection_form.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AuthService authService = AuthService();
  User user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _unitName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<int> _selectedItems = [];
  final List<int> _selectedIndexes = [];
  final year = ['1st', '2rd', '3rd', '4th'];

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
        body: Column(
      children: [
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<dynamic> classes = snapshot.data?.get('department');
              return Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) => Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "card",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                '3rd year',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        )),
              );
            }),
        FloatingActionButton(onPressed: createClasses)
      ],
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
                    labelText: "Unit Name",
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter unit name ' : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                Multiselect(
                  dropList: year,
                  title: 'hey',
                  onChanged: (selectedItems) {
                    setState(() {
                      for (dynamic item in selectedItems) {
                        _selectedIndexes.add(item as int);
                      }

                      _selectedItems = List.from(
                          _selectedIndexes.map((index) => year[index]));
                    });
                  },
                  // submit: ElevatedButton(
                  //     onPressed: () {}, child: const Text('submit')),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {}, child: const Text('Cancel')),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          print('object');
                          for (var item in _selectedItems) {
                            print(item);
                          }
                        },
                        child: const Text('Create'))
                  ],
                )
              ]),
            ),
          );
        });
  }

  addClasses(String unit, List<String> year) {
    FirebaseFirestore.instance
        .collection("final users")
        .doc("final user")
        .update({
      "classes": FieldValue.arrayUnion([unit])
    });
    createUnit(unit, year);
  }

  createUnit(String unitName, List<String> year) {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = FirebaseAuth.instance.currentUser;
    CollectionReference ref = firebaseFirestore.collection('Classes');
    ref.add({
      'unit_name': unitName,
      'lecture_id': user!.uid,
      'year': year,
      'classes': []
    });
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

class Class {
  String name;
  String lecturerId;
  List<AttendanceHistory> attendanceHistory;

  Class(this.name, this.lecturerId, this.attendanceHistory);

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': lecturerId,
        'student': attendanceHistory,
      };
}

class AttendanceHistory {
  String studentNames;
  String regNo;
  String signUpTime;
  AttendanceHistory(this.studentNames, this.regNo, this.signUpTime);
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
