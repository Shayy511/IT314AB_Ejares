import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/academic_record.dart';

class AcademicRecordRepository {
  Future<List<AcademicRecord>> getStudentRecords(int studentId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        SELECT
          enrollment_id,
          student_id,
          subject_code,
          subject_name,
          units,
          day_of_week,
          LEFT(start_time::text, 5) AS start_time,
          LEFT(end_time::text, 5) AS end_time,
          room,
          enrollment_status,
          grade,
          remarks
        FROM student_academic_records
        WHERE student_id = @student_id
          AND enrollment_status = 'Enrolled'
        ORDER BY subject_code
      '''),
      parameters: {'student_id': studentId},
    );

    return result.map((row) {
      return AcademicRecord.fromMap(row.toColumnMap());
    }).toList();
  }
}
