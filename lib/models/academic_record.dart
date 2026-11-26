class AcademicRecord {
  final int enrollmentId;
  final int studentId;
  final String subjectCode;
  final String subjectName;
  final int units;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String enrollmentStatus;
  final double? grade;
  final String remarks;

  const AcademicRecord({
    required this.enrollmentId,
    required this.studentId,
    required this.subjectCode,
    required this.subjectName,
    required this.units,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.enrollmentStatus,
    this.grade,
    required this.remarks,
  });

  factory AcademicRecord.fromMap(Map<String, dynamic> map) {
    return AcademicRecord(
      enrollmentId: map['enrollment_id'] as int,
      studentId: map['student_id'] as int,
      subjectCode: map['subject_code'] as String,
      subjectName: map['subject_name'] as String,
      units: map['units'] as int,
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String,
      enrollmentStatus: map['enrollment_status'] as String,
      grade: map['grade'] == null
          ? null
          : double.parse(map['grade'].toString()),
      remarks: map['remarks'] as String,
    );
  }

  bool get isPassed => grade != null && grade! >= 75;
}
