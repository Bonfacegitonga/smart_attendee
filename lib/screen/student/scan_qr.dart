import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../auth/auth_service.dart';
import '../../auth/sign_in/login.dart';
import '../../component/drawer.dart';
import '../../constant/constant.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User user = FirebaseAuth.instance.currentUser!;
  AuthService authService = AuthService();
  String? fName;
  String? sName;
  String? role;
  List<dynamic>? unitCourse;
  String? myCourse;
  String? fullNames;
  String? registrationNumber;
  String uid = "";
  String courseName = "";
  String couseCode = "";
  Timestamp? timestamp;
  Map? studentInfo;
  Map? courseInfo;

  Future<void> scanQR() async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);

    if (!mounted) return;

    setState(() {
      uid = barcodeScanRes;
    });

    addClasses();
  }

  Future getUser() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    if (documentSnapshot.exists) {
      setState(() {
        fName = documentSnapshot.get('last_name');
        sName = documentSnapshot.get('first_name');
        registrationNumber = documentSnapshot.get('Id');
        role = documentSnapshot.get('role');
        myCourse = documentSnapshot.get('course');
        fullNames = '$fName $sName';
        studentInfo = {
          "Names": fullNames,
          "reg_no": registrationNumber,
          "time": DateTime.now()
        };
      });
    }
    //await addClasses();
  }

  Future getClassDocument() async {
    final classDoc =
        await FirebaseFirestore.instance.collection("Classes").doc(uid).get();
    try {
      if (classDoc.exists) {
        setState(() {
          unitCourse = classDoc.get("classes");
          courseInfo = {
            'unitName': classDoc.get('unit_name'),
            'unitCode': classDoc.get('unit_code'),
            'time': DateTime.now()
          };
        });
      }
    } on FirebaseException catch (e) {
      if (e.code == 'cloud_firestore/not-found') {
        showErr('Class not found');
      }
    }
  }

  showErr(String err) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(err),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  successSnack() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Class attended successfully'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  addAttendance() async {
    await getClassDocument();
    if (unitCourse!.contains(myCourse)) {
      FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        "history": FieldValue.arrayUnion([courseInfo])
      });
      successSnack();
    } else {
      showErr('You are not enrolled to this unit');
    }
  }

  addClasses() async {
    FirebaseFirestore.instance.collection("Classes").doc(uid).update({
      "student_attendance": FieldValue.arrayUnion([studentInfo])
    }).then((_) => addAttendance());
  }

  Future<Map<String, dynamic>> fetchStudentData(String documentId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('students')
            .doc(documentId)
            .get();

    return snapshot.data()!['student'] as Map<String, dynamic>;
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String nameRole = '$fullNames ($role)';
    return Scaffold(
        drawer: MyDrawer(
          names: nameRole.toString().toUpperCase(),
          email: user.email.toString(),
          signOut: authService.logout,
        ),
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("Student"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(9),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "error!!",
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Text('Loading...'));
              }

              List<dynamic> history = snapshot.data!['history'];
              if (history.isEmpty) {
                return const Center(child: Text('No attendance made yet'));
              }
              return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> hist = history[index];

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hist['unitName'].toUpperCase(),
                              style: GoogleFonts.inconsolata(
                                  fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            Text(
                                DateFormat.yMMMMd('en_US')
                                    .format(hist['time'].toDate()),
                                style: GoogleFonts.inter(
                                    color:
                                        const Color.fromARGB(255, 199, 84, 8)))
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hist['unitCode'],
                              style: GoogleFonts.inconsolata(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            Text(
                              DateFormat('hh:mm a')
                                  .format(hist['time'].toDate()),
                            )
                          ],
                        ),
                        const Divider(
                          thickness: 1.5,
                        )
                      ],
                    );
                  });
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: () {
            scanQR();
          },
          child: const Icon(Icons.qr_code_scanner_outlined),
        ));
  }

  Future<void> _getUserData() async {
    final classDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (classDoc.exists) {
      setState(() {});
    }
  }
}

class Student {
  final String names;
  final String regNo;

  Student({required this.names, required this.regNo});
}

Future<List<Student>> fetchStudentList() async {
  final QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('students').get();

  return snapshot.docs
      .map((doc) =>
          Student(names: doc.data()['Names'], regNo: doc.data()['reg_no']))
      .toList();
}
