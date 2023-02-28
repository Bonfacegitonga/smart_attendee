import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../auth/sign_in/login.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String? fName;
  String? sName;
  String? fullNames;
  String? registrationNumber;
  String _scanBarcode = '';
  String uid = "";
  String courseName = "";
  String couseCode = "";
  Timestamp? timestamp;
  Map? studentInfo;

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
    User user = FirebaseAuth.instance.currentUser!;
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

  // Future<void> getClassDocument() async {
  //   final classDoc =
  //       await FirebaseFirestore.instance.collection("Classes").doc(uid).get();
  //   if (classDoc.exists) {
  //     setState(() {
  //       courseName = classDoc.get('field');
  //       couseCode = classDoc.get('field');
  //       timestamp = classDoc.get('field');
  //     });
  //   }
  // }

  addClasses() async {
    FirebaseFirestore.instance.collection("Classes").doc(uid).update({
      "student_attendance": FieldValue.arrayUnion([studentInfo])
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("QR Scanner")),
        body: Column(
          children: [
            Center(
              child: ElevatedButton(
                  onPressed: (() {
                    scanQR();
                  }),
                  child: const Text("scan qr")),
            ),
            ElevatedButton(
                onPressed: () {
                  logout(context);
                },
                child: const Text("sign out"))
          ],
        ));
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this._controller = controller;
  //   controller.scannedDataStream.listen((scanData) async {
  //     setState(() {
  //       uid = scanData.code!;
  //     });
  //     await _controller?.pauseCamera();
  //     _controller?.dispose();
  //     await _getUserData();
  //     await _createClassDocument();
  //   });
  // }
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
