import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceHistory extends StatefulWidget {
  final List<dynamic> attendanceHistory;
  const AttendanceHistory({super.key, required this.attendanceHistory});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  //AuthService authService = AuthService();
  User user = FirebaseAuth.instance.currentUser!;
  CollectionReference classesRef =
      FirebaseFirestore.instance.collection('Classes');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: widget.attendanceHistory.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic> recordData = widget.attendanceHistory[index];
              String studentName = recordData['Names'];
              String regNo = recordData['reg_no'];
              //TimeOfDay time = recordData['time'];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          studentName.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "11-11-2019",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          regNo,
                          //textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
