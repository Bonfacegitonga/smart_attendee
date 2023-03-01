import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../auth/sign_in/login.dart';
import '../../constant/constant.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User user = FirebaseAuth.instance.currentUser!;
  String? fName;
  String? sName;
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

  Future<void> getClassDocument() async {
    final classDoc =
        await FirebaseFirestore.instance.collection("Classes").doc(uid).get();
    if (classDoc.exists) {
      setState(() {
        courseInfo = {
          'unitName': classDoc.get('unit_name'),
          'unitCode': classDoc.get('unit_code'),
          'time': DateTime.now()
        };
      });
    }
  }

  addAttendance() async {
    await getClassDocument();
    FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      "history": FieldValue.arrayUnion([courseInfo])
    });
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("QR Scanner"),
          actions: [
            IconButton(
                onPressed: () {
                  logout(context);
                },
                icon: const Icon(Icons.logout))
          ],
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
              return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> hist = history[index];

                    return ListTile(
                      title: Text(hist['unitName'].toString()),
                      subtitle: Text(hist['unitCode'].toString()),
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
