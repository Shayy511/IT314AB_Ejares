import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/grade.dart';
import '../models/enrollment.dart';
import 'enrollment_repository.dart';

class GradeRepository {
  final EnrollmentRepository _enrollmentRepository = EnrollmentRepository();

  Future<List<Grade>> getGrades() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT *
      FROM student_grade_details
      ORDER BY student_name, subject_code
    ''');

    return result.map((row) {
      return Grade.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<List<Enrollment>> getActiveEnrollments() async {
    final enrollments = await _enrollmentRepository.getEnrollments();

    return enrollments.where((enrollment) {
      return enrollment.isEnrolled;
    }).toList();
  }

  Future<void> addGrade(Grade grade) async {
    final connection = await DBConnection.connect();

    await connection.execute(
      Sql.named('''
        INSERT INTO enrollment_grades (
          enrollment_id,
          grade
        )
        VALUES (
          @enrollment_id,
          CAST(@grade AS NUMERIC)
        )
      '''),
      parameters: grade.toMap(),
    );
  }

  Future<void> updateGrade(Grade grade) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        UPDATE enrollment_grades
        SET grade = CAST(@grade AS NUMERIC)
        WHERE grade_id = @grade_id
      '''),
      parameters: {'grade': grade.grade.toString(), 'grade_id': grade.gradeId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Grade not found.');
    }
  }

  Future<void> deleteGrade(int gradeId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        DELETE FROM enrollment_grades
        WHERE grade_id = @grade_id
      '''),
      parameters: {'grade_id': gradeId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Grade not found.');
    }
  }
}
