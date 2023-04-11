import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String firstName;
  final String lastName;
  final String regNo;
  final DateTime checkedInAt;

  Attendance({
    required this.firstName,
    required this.lastName,
    required this.checkedInAt,
    required this.regNo,
  });

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Attendance(
      firstName: data['firstName'],
      lastName: data['lastName'],
      regNo: data['regNo'],
      checkedInAt: (data['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'regNo': regNo,
      'time': Timestamp.fromDate(checkedInAt),
    };
  }
}
