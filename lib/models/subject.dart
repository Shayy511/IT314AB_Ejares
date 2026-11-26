class Subject {
  final int? subjectId;
  final String subjectCode;
  final String subjectName;
  final int units;

  const Subject({
    this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.units,
  });

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      subjectId: map['subject_id'] as int,
      subjectCode: map['subject_code'] as String,
      subjectName: map['subject_name'] as String,
      units: map['units'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'units': units,
    };
  }
}
