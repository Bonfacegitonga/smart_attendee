import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_attendee/screen/admin/admin_home.dart';
import 'package:smart_attendee/screen/student/student_home.dart';

class RoleScreen extends StatefulWidget {
  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userRole;

  @override
  void initState() {
    super.initState();
    _checkRoleAndNavigate();
  }

  Future _checkRoleAndNavigate() async {
    User user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('Users').doc(user.uid).get();
    if (documentSnapshot.exists) {
      setState(() {
        _userRole = documentSnapshot.get('role');
      });
      routes();
    }
  }

  routes() {
    if (_userRole == 'Student') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const StudentHomePage()));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AdminHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
