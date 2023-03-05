import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/auth/sign_in/login.dart';

import '../main.dart';
import '../screen/admin/admin_home.dart';
import '../screen/student/student_home.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future signIn(
    BuildContext context,
    String email,
    String password,
  ) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e);
      //err.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    login(context);
  }

  login(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ));
  }

  // Future signIn(BuildContext context, String email, String password) async {
  //   // showDialog(
  //   //     context: context,
  //   //     barrierDismissible: false,
  //   //     builder: (context) => const Center(
  //   //           child: CircularProgressIndicator(),
  //   //         ));
  //   try {
  //     await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email, password: password);
  //     route;
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //     //err.showSnackBar(e.message);
  //   }
  //   //navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }

  // void route(BuildContext context) {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   var kk = FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(user!.uid)
  //       .get()
  //       .then((DocumentSnapshot documentSnapshot) {
  //     if (documentSnapshot.exists) {
  //       if (documentSnapshot.get('role') == "Student") {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const StudentHomePage(),
  //           ),
  //         );
  //       } else {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const AdminHomePage(),
  //           ),
  //         );
  //       }
  //     } else {
  //       print('Document does not exist on the database');
  //     }
  //   });
  // }
}
