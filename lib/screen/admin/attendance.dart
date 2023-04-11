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
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

import '../../model/admin.dart';

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
  List<Attendance> classHistory = [];

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
    fetchAttendance();
    super.initState();
  }

  void fetchAttendance() {
    FirebaseFirestore.instance
        .collection('Classes')
        .doc(widget.documentLink)
        .collection('history')
        .snapshots()
        .listen((snapshot) {
      // Create a list of Message objects from the Firestore documents.
      List<Attendance> updated = [];
      for (var doc in snapshot.docs) {
        Attendance history = Attendance.fromFirestore(doc);
        updated.add(history);
      }

      // Update the app state with the new list of messages.
      setState(() {
        classHistory = updated;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = user.email;
    final String myrole = role.toString();
    final String fullNames = '$fName $sName ($myrole)';

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
        child: StickyGroupedListView<Attendance, DateTime>(
          elements: classHistory,
          order: StickyGroupedListOrder.DESC,
          groupBy: (Attendance element) => DateTime(
            element.checkedInAt.year,
            element.checkedInAt.month,
            element.checkedInAt.day,
          ),
          groupComparator: (DateTime value1, DateTime value2) =>
              value1.compareTo(value2),
          itemComparator: (Attendance element1, Attendance element2) =>
              element1.checkedInAt.compareTo(element2.checkedInAt),
          floatingHeader: true,
          groupSeparatorBuilder: _getGroupSeparator,
          itemBuilder: _getItem,
        ),
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

  Widget _getItem(BuildContext ctx, Attendance info) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${info.firstName.toUpperCase()} ${info.lastName.toUpperCase()}",
              style: GoogleFonts.inconsolata(
                  fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(
              DateFormat('hh:mm a').format(info.checkedInAt),
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
              info.regNo,
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

  Widget _getGroupSeparator(Attendance element) {
    return Chip(
      label: Text(
        formatDateTime(element.checkedInAt),
        //DateFormat.yMMMMd('en_US').format(element.createdAt),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: oPrimaryColor,
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
                  ...classHistory.map((attendance) {
                    final date = DateFormat.yMMMMd('en_US')
                        .format(attendance.checkedInAt);
                    final name =
                        "${attendance.firstName.toUpperCase()} ${attendance.lastName.toUpperCase()}";
                    final regNo = attendance.regNo;
                    final time =
                        DateFormat('hh:mm a').format(attendance.checkedInAt);
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
