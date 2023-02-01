import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendee/admin/admin_home.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool _isUserLecturer = false;

  @override
  void initState() {
    whichUser();
    super.initState();
  }

  Future whichUser() async {
    User user = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot student = await FirebaseFirestore.instance
        .collection('Admins')
        .doc(user.uid)
        .get();
    if (student.exists) {
      setState(() {
        _isUserLecturer = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _isUserLecturer
      ? const AdminHomePage()
      : Scaffold(
          body: Column(
            children: [
              const Center(child: Text("student")),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  onPressed: signOut,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 32,
                  ),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(fontSize: 24),
                  ))
            ],
          ),
        );

  Future signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
