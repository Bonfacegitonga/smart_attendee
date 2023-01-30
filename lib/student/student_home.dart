import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Column(
      children: [
        Center(child: Text(user.email!)),
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
    );
  }

  Future signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
