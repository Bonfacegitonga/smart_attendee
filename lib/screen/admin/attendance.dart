import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceHistory extends StatefulWidget {
  //final String documentLink;
  final String title;
  final List<dynamic> attendanceHistory;
  const AttendanceHistory({
    super.key,
    required this.attendanceHistory,
    required this.title,
  });

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
      appBar: AppBar(
        leading: IconButton(
          //iconSize: 72,
          icon: const Icon(Icons.menu),
          onPressed: () {
            // ...
          },
        ),
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const Text(
                          "11-11-2019",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
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
