class Program {
  final int programId;
  final String programCode;
  final String programName;

  const Program({
    required this.programId,
    required this.programCode,
    required this.programName,
  });

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      programId: map['program_id'] as int,
      programCode: map['program_code'] as String,
      programName: map['program_name'] as String,
    );
  }
}
