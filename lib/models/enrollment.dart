class Enrollment {
  final int enrollmentId;
  final int studentId;
  final int scheduleId;
  final String studentName;
  final String? schoolId;
  final String subjectCode;
  final String subjectName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String status;
  final String enrollmentDate;

  const Enrollment({
    required this.enrollmentId,
    required this.studentId,
    required this.scheduleId,
    required this.studentName,
    this.schoolId,
    required this.subjectCode,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.status,
    required this.enrollmentDate,
  });

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      enrollmentId: map['enrollment_id'] as int,
      studentId: map['student_id'] as int,
      scheduleId: map['schedule_id'] as int,
      studentName: map['student_name'] as String,
      schoolId: map['school_id'] as String?,
      subjectCode: map['subject_code'] as String,
      subjectName: map['subject_name'] as String,
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String,
      status: map['status'] as String,
      enrollmentDate: map['enrollment_date'].toString(),
    );
  }

  bool get isEnrolled => status == 'Enrolled';
}

class AvailableSchedule {
  final int scheduleId;
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final int capacity;
  final int enrolledStudents;
  final int availableSlots;

  const AvailableSchedule({
    required this.scheduleId,
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.capacity,
    required this.enrolledStudents,
    required this.availableSlots,
  });

  factory AvailableSchedule.fromMap(Map<String, dynamic> map) {
    return AvailableSchedule(
      scheduleId: map['schedule_id'] as int,
      subjectId: map['subject_id'] as int,
      subjectCode: map['subject_code'] as String,
      subjectName: map['subject_name'] as String,
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String,
      capacity: map['capacity'] as int,
      enrolledStudents: map['enrolled_students'] as int,
      availableSlots: map['available_slots'] as int,
    );
  }
}
