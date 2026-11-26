class Schedule {
  final int? scheduleId;
  final int subjectId;
  final String? subjectCode;
  final String? subjectName;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final int capacity;
  final int enrolledStudents;
  final int availableSlots;

  const Schedule({
    this.scheduleId,
    required this.subjectId,
    this.subjectCode,
    this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.capacity,
    this.enrolledStudents = 0,
    this.availableSlots = 0,
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      scheduleId: map['schedule_id'] as int,
      subjectId: map['subject_id'] as int,
      subjectCode: map['subject_code'] as String?,
      subjectName: map['subject_name'] as String?,
      dayOfWeek: map['day_of_week'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String,
      capacity: map['capacity'] as int,
      enrolledStudents: map['enrolled_students'] as int? ?? 0,
      availableSlots: map['available_slots'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject_id': subjectId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'capacity': capacity,
    };
  }
}
