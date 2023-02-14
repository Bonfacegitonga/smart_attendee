class Class {
  final String courseName;
  final String courseCode;
  //String classLink;

  const Class({
    required this.courseName,
    required this.courseCode,
  });

  // Map<String, dynamic> toJson() => {
  //       'name': name,
  //       'id': lecturerId,
  //       'student': attendanceHistory,
  //     };
}

class AttendanceHistory {
  String studentNames;
  String regNo;
  String signUpTime;
  AttendanceHistory(this.studentNames, this.regNo, this.signUpTime);
}

class Student {
  String id;
  String name;
  Student(this.id, this.name);
}

void main() {
  // Create a list
  List myList = [];
  myList.add(Student('15GH1239', 'Maria'));
  myList.add(Student('15GH1243', 'Paul'));
  myList.add(Student('15GH1009', 'Jane'));

  // Convert the list to a map
  // Using fromIterable()

  var map1 = Map.fromIterable(myList, key: (e) => e.id, value: (e) => e.name);
  print(map1);
}
