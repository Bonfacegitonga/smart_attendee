import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendee/model/admin.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../auth/auth_service.dart';
import '../../auth/sign_in/login.dart';
import '../../component/drawer.dart';
import '../../constant/constant.dart';
import '../../model/StudentClasses.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User user = FirebaseAuth.instance.currentUser!;
  AuthService authService = AuthService();
  String fName = "";
  String sName = "";
  String? role;
  List<dynamic>? unitCourse;
  String? myCourse;
  String? fullNames;
  String registrationNumber = "";
  String uid = "";
  String courseName = "";
  String couseCode = "";
  DateTime time = DateTime.now();
  Map? studentInfo;
  Map? courseInfo;
  Map<String, dynamic> qrData = {};
  int timestamp = 0;
  List<StudentClasses> myClasses = [];

//scan qr code
  Future<void> scanQR() async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);

    if (!mounted) return;

    setState(() {
      qrData = jsonDecode(barcodeScanRes);
      uid = qrData['documentId'];
      timestamp = qrData['timestamp'];
    });

    addClasses();
  }

//set user details
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

// qrcode id dicument
  Future getClassDocument() async {
    final classDoc =
        await FirebaseFirestore.instance.collection("Classes").doc(uid).get();
    try {
      if (classDoc.exists) {
        setState(() {
          unitCourse = classDoc.get("classes");
          courseName = classDoc.get('unit_name');
          couseCode = classDoc.get('unit_code');
          time = DateTime.now();
          // courseInfo = {
          //   'unitName': classDoc.get('unit_name'),
          //   'unitCode': classDoc.get('unit_code'),
          //   'time': DateTime.now()
          // };
        });
      }
    } on FirebaseException catch (e) {
      if (e.code == 'cloud_firestore/not-found') {
        showErr('Class not found');
      }
    }
  }

  //snackbar to show error
  showErr(String err) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(err),
        duration: const Duration(seconds: 5),
      ),
    );
  }

//SnackBar to display success scanning
  successSnack() {
    return ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Class attended successfully'),
        duration: Duration(seconds: 5),
      ),
    );
  }

//send class details to firebase
  addAttendance() async {
    final bool isValid =
        DateTime.now().millisecondsSinceEpoch - timestamp <= 20 * 60 * 1000;

    await getClassDocument();
    StudentClasses myClasse = StudentClasses(
        courseCode: couseCode, courseName: courseName, createdAt: time);
    if (unitCourse!.contains(myCourse)) {
      if (isValid) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('history')
            .add(myClasse.toFirestore());
        successSnack();
      } else {
        showErr('Qr code has expired');
      }
    } else {
      showErr('You are not enrolled to this unit');
    }
  }

//update class attendance history
  addClasses() async {
    //getUser();
    Attendance studentDetail = Attendance(
        firstName: fName,
        lastName: sName,
        checkedInAt: DateTime.now(),
        regNo: registrationNumber);

    FirebaseFirestore.instance
        .collection("Classes")
        .doc(uid)
        .collection('history')
        .add(studentDetail.toFirestore())
        .then((_) => addAttendance());
  }

  void fetchStudentClasses() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('history')
        .snapshots()
        .listen((snapshot) {
      // Create a list of Message objects from the Firestore documents.
      List<StudentClasses> updatedMessages = [];
      for (var doc in snapshot.docs) {
        StudentClasses message = StudentClasses.fromFirestore(doc);
        updatedMessages.add(message);
      }

      // Update the app state with the new list of messages.
      setState(() {
        myClasses = updatedMessages;
      });
    });
  }

  @override
  void initState() {
    getUser();
    fetchStudentClasses();
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
          title: const Text("Attendance history"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(9),
          child: StickyGroupedListView<StudentClasses, DateTime>(
            elements: myClasses,
            order: StickyGroupedListOrder.DESC,
            groupBy: (StudentClasses element) => DateTime(
              element.createdAt.year,
              element.createdAt.month,
              element.createdAt.day,
            ),
            groupComparator: (DateTime value1, DateTime value2) =>
                value1.compareTo(value2),
            itemComparator:
                (StudentClasses element1, StudentClasses element2) =>
                    element1.createdAt.compareTo(element2.createdAt),
            floatingHeader: true,
            groupSeparatorBuilder: _getGroupSeparator,
            itemBuilder: _getItem,
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

  Widget _getGroupSeparator(StudentClasses element) {
    return Chip(
      label: Text(
        formatDateTime(element.createdAt),
        //DateFormat.yMMMMd('en_US').format(element.createdAt),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: oPrimaryColor,
    );
  }

  Widget _getItem(BuildContext ctx, StudentClasses units) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units.courseName.toUpperCase(),
              style: GoogleFonts.inconsolata(
                  fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              DateFormat('hh:mm a').format(units.createdAt),
            )
          ],
        ),
        const SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units.courseCode,
              style: GoogleFonts.inconsolata(
                  fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
        const Divider(
          thickness: 1.5,
        )
      ],
    );
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == today.day) {
      return 'Today';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}
