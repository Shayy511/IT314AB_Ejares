class Student {
  final int? studentId;
  final int? programId;
  final int? yearLevel;
  final int? age;

  final String? schoolId;
  final String? programCode;
  final String? email;
  final String? hobby;
  final String? favoriteSubject;
  final String? imagePath;

  final String studentName;
  final double? height;
  final bool isActive;
  final bool isFavorite;

  const Student({
    this.studentId,
    this.programId,
    this.yearLevel,
    this.age,
    this.schoolId,
    this.programCode,
    this.email,
    this.hobby,
    this.favoriteSubject,
    this.imagePath,
    required this.studentName,
    this.height,
    this.isActive = true,
    this.isFavorite = false,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      studentId: map['student_id'] as int,
      studentName: map['student_name'] as String,
      schoolId: map['school_id'] as String?,
      programId: map['program_id'] as int?,
      programCode: map['program_code'] as String?,
      yearLevel: map['year_level'] as int?,
      age: map['age'] as int?,
      email: map['email'] as String?,
      hobby: map['hobby'] as String?,
      height: double.tryParse(map['height'].toString()),
      favoriteSubject: map['favorite_subject'] as String?,
      imagePath: map['image'] as String?,
      isActive: map['is_active'] as bool,
      isFavorite: map['is_favorite'] as bool,
    );
  }

  String get displayId {
    return schoolId ?? studentId.toString();
  }

  String get course {
    return '${programCode ?? "Not assigned"}'
        '${yearLevel == null ? "" : " $yearLevel"}';
  }

  Map<String, dynamic> toMap() {
    return {
      'student_name': studentName,
      'school_id': schoolId,
      'program_id': programId,
      'year_level': yearLevel,
      'email': email,
      'age': age,
      'hobby': hobby,
      'height': height?.toString(),
      'favorite_subject': favoriteSubject,
      'image': imagePath,
      'is_active': isActive,
      'is_favorite': isFavorite,
    };
  }
}
