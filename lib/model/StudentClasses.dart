import 'package:cloud_firestore/cloud_firestore.dart';

class StudentClasses {
  final String courseCode;
  final String courseName;
  final DateTime createdAt;

  StudentClasses({
    required this.courseCode,
    required this.courseName,
    required this.createdAt,
  });

  factory StudentClasses.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StudentClasses(
      courseCode: data['unitCode'],
      courseName: data['unitName'],
      createdAt: (data['time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'unitCode': courseCode,
      'unitName': courseName,
      'time': Timestamp.fromDate(createdAt),
    };
  }
}
