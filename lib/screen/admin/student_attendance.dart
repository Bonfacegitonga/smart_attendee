// import 'package:cloud_firestore/cloud_firestore.dart';

// class StudentAttendance {
//   final String name;
//   final String registrationNumber;
//   final int timestamp;

//   StudentAttendance(
//       {required this.name,
//       required this.registrationNumber,
//       required this.timestamp});
// }

// Future<List<StudentAttendance>> getClassAttendance(
//     String classId, String attendanceId) async {
//   List<StudentAttendance> studentAttendance = [];

//   DocumentReference<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
//       .instance.collection('Classes').doc(docId);
                     
//       // .collection('classes')
//       // .doc(classId)
//       // .collection('classattendance')
//       // .doc(attendanceId)
//       // .get();
//   List<dynamic> studentData = querySnapshot.data()!['students'];

//   for (var data in studentData) {
//     String name = data['name'];
//     String regNo = data['registrationNumber'];
//     int timestamp = data['timestamp'];
//     StudentAttendance attendance = StudentAttendance(
//         name: name, registrationNumber: regNo, timestamp: timestamp);
//     studentAttendance.add(attendance);
//   }

//   return studentAttendance;
// }
