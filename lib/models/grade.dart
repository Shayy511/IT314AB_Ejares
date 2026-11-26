class Grade {
  final int? gradeId;
  final int enrollmentId;
  final int? studentId;
  final String? schoolId;
  final String? studentName;
  final String? subjectCode;
  final String? subjectName;
  final double grade;
  final String? enrollmentStatus;
  final String? dateRecorded;

  const Grade({
    this.gradeId,
    required this.enrollmentId,
    this.studentId,
    this.schoolId,
    this.studentName,
    this.subjectCode,
    this.subjectName,
    required this.grade,
    this.enrollmentStatus,
    this.dateRecorded,
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      gradeId: map['grade_id'] as int,
      enrollmentId: map['enrollment_id'] as int,
      studentId: map['student_id'] as int,
      schoolId: map['school_id'] as String?,
      studentName: map['student_name'] as String?,
      subjectCode: map['subject_code'] as String?,
      subjectName: map['subject_name'] as String?,
      grade: double.parse(map['grade'].toString()),
      enrollmentStatus: map['enrollment_status'] as String?,
      dateRecorded: map['date_recorded'].toString(),
    );
  }

  String get remarks {
    return grade >= 75 ? 'Passed' : 'Failed';
  }

  bool get isPassed => grade >= 75;

  Map<String, dynamic> toMap() {
    return {'enrollment_id': enrollmentId, 'grade': grade.toString()};
  }
}
