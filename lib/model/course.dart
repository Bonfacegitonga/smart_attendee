// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUnit {
  String id;
  Map<String, dynamic> data;

  MyUnit({required this.id, required this.data});

  factory MyUnit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MyUnit(id: doc.id, data: data);
  }
}

Future<List<MyUnit>> getMyUnits() async {
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('Users').get();
  List<MyUnit> myUnits =
      querySnapshot.docs.map((doc) => MyUnit.fromFirestore(doc)).toList();
  return myUnits;
}



// class Class {
//   final String id;
//   final String lecturerId;
//   final List<Unit> units;

//   Class({this.id, this.lecturerId, this.units});

//   factory Class.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data as Map;

//     List<Unit> units = (data['units'] as List).map((unit) => units.fromMap(unit)).toList();

//     return Class(
//       id: doc.documentID,
//       lecturerId: data['lecturerId'],
//       units: units,
//     );
//   }

//   Map<String, dynamic> toFirestore() => {
//         'lecturerId': lecturerId,
//         'units': units.map((unit) => unit.toMap()).toList(),
//       };
// }

// class AttendanceHistory {
//   final String studentName;
//   final String registrationNumber;
//   final Timestamp signupTime;

//   AttendanceHistory ( this.studentName, this.registrationNumber, this.signupTime);

//   factory AttendanceHistory .fromMap(Map data) {
//     return Unit(
//       studentName: data['studentName'],
//       registrationNumber: data['registrationNumber'],
//       signupTime: data['signupTime'],
//     );
//   }

//   Map<String, dynamic> toMap() => {
//         'studentName': studentName,
//         'registrationNumber': registrationNumber,
//         'signupTime': signupTime,
//       };
// }

// class FirebaseService {
//   final CollectionReference classesCollection = FirebaseFirestore.instance.collection('classes');

//   Future<void> addClass(Class classToAdd) async {
//     return await classesCollection.doc(classToAdd.id).set(classToAdd.toFirestore());
//   }

//   Stream<List<Class>> get classes {
//     return classesCollection.snapshots().map((snapshot) => snapshot.documents
//         .map((doc) => Class.fromFirestore(doc))
//         .toList());
//   }
// }

