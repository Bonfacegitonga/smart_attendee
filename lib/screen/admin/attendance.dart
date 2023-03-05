import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:smart_attendee/auth/auth_service.dart';
import 'package:smart_attendee/component/drawer.dart';
import 'package:smart_attendee/constant/constant.dart';
import 'package:smart_attendee/screen/admin/qr_code.dart';
import 'package:pdf/widgets.dart' as pw;

class AttendanceHistory extends StatefulWidget {
  final String cName;
  final String cCode;
  final String documentLink;
  final String title;
  final List<dynamic> attendanceHistory;
  const AttendanceHistory({
    super.key,
    required this.attendanceHistory,
    required this.title,
    required this.cName,
    required this.cCode,
    required this.documentLink,
  });

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  //AuthService authService = AuthService();
  User user = FirebaseAuth.instance.currentUser!;
  CollectionReference classesRef =
      FirebaseFirestore.instance.collection('Classes');
  AuthService authService = AuthService();
  String? fName;
  String? sName;
  String? role;

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
        role = documentSnapshot.get('role');
      });
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //widget.attendanceHistory.sort((a, b) => a.time.compareTo(b.time));
    final List<List<Map<String, dynamic>>> groupedAttendance = [];
    DateTime? currentDate;
    List<Map<String, dynamic>>? currentGroup;
    final email = user.email;
    final String myrole = role.toString();
    final String fullNames = '$fName $sName ($myrole)';

    for (final Map<String, dynamic> attendance in widget.attendanceHistory) {
      final DateTime date = attendance['time'].toDate();

      if (currentDate == null || date.difference(currentDate).inDays != 0) {
        if (currentGroup != null) {
          groupedAttendance.add(currentGroup);
        }

        currentDate = date;
        currentGroup = [attendance];
      } else {
        currentGroup!.add(attendance);
      }
    }

    if (currentGroup != null) {
      groupedAttendance.add(currentGroup);
    }

    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      drawer: MyDrawer(
        signOut: authService.logout,
        email: email.toString(),
        names: fullNames.toUpperCase(),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: groupedAttendance.length,
            itemBuilder: (BuildContext context, int index) {
              ///Map<String, dynamic> recordData = widget.attendanceHistory[index];
              final List<Map<String, dynamic>> attendanceList =
                  groupedAttendance[index];
              final String date = DateFormat.yMMMMd('en_US')
                  .format(attendanceList[index]['time'].toDate());
              final List<Widget> children = [];

              for (final Map<String, dynamic> attendance
                  in attendanceList.reversed) {
                children.add(Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            attendance['Names'].toUpperCase(),
                            style: GoogleFonts.inconsolata(
                                fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                          Text(
                              DateFormat.yMMMMd('en_US')
                                  .format(attendance['time'].toDate()),
                              style: GoogleFonts.inter(
                                  color: const Color.fromARGB(255, 199, 84, 8)))
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            attendance['reg_no'],
                            style: GoogleFonts.inconsolata(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                          Text(
                            DateFormat('hh:mm a')
                                .format(attendance['time'].toDate()),
                          )
                        ],
                      ),
                      const Divider(
                        thickness: 1.5,
                      )
                    ]));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  // Text(date,
                  //     style: GoogleFonts.inter(
                  //         color: const Color.fromARGB(255, 199, 84, 8),
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600)),
                  // const SizedBox(height: 10),
                  ...children,
                  const SizedBox(height: 16),
                ],
              );
            }),
      ),
      floatingActionButton: ExpandableFab(
        backgroundColor: kPrimaryColor,
        distance: 60,
        type: ExpandableFabType.up,
        children: [
          FloatingActionButton.small(
            backgroundColor: kPrimaryColor,
            heroTag: null,
            tooltip: 'Download pdf',
            child: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              _generatePdf();
            },
          ),
          FloatingActionButton.small(
            backgroundColor: kPrimaryColor,
            heroTag: null,
            tooltip: 'Generate Qr',
            child: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QrCodeShare(
                            classLink: widget.documentLink,
                            courseName: widget.cName,
                            courseCode: widget.cCode,
                          )));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    // Create a new PDF document
    final pdf = pw.Document();

    // Add a title to the document
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('Attendance History')),
            pw.Padding(padding: const pw.EdgeInsets.all(16)),
            pw.Table.fromTextArray(
                data: [
                  ['Date', 'Name', 'Registration No.', 'Time'],
                  ...widget.attendanceHistory.map((attendance) {
                    final date = DateFormat.yMMMMd('en_US')
                        .format(attendance['time'].toDate());
                    final name = attendance['Names'].toUpperCase();
                    final regNo = attendance['reg_no'];
                    final time = DateFormat('hh:mm a')
                        .format(attendance['time'].toDate());
                    return [date, name, regNo, time];
                  }).toList(),
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(width: 1),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                }),
          ];
        }));

    // Save the PDF document to a file
    final bytes = await pdf.save();
    final fileName = 'AttendanceHistory_${widget.cCode}.pdf';
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Open the PDF document with the default PDF viewer app
    await OpenFile.open(file.path);
  }
}
