import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/enrollment.dart';

class EnrollmentRepository {
  Future<List<Enrollment>> getEnrollments() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT
        e.enrollment_id,
        e.student_id,
        e.schedule_id,
        st.student_name,
        st.school_id,
        su.subject_code,
        su.subject_name,
        sc.day_of_week,
        LEFT(sc.start_time::text, 5) AS start_time,
        LEFT(sc.end_time::text, 5) AS end_time,
        sc.room,
        e.status,
        e.enrollment_date
      FROM enrollments e
      JOIN students st
        ON e.student_id = st.student_id
      JOIN schedules sc
        ON e.schedule_id = sc.schedule_id
      JOIN subjects su
        ON sc.subject_id = su.subject_id
      ORDER BY e.enrollment_id DESC
    ''');

    return result.map((row) {
      return Enrollment.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<List<AvailableSchedule>> getAvailableSchedules() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT
        schedule_id,
        subject_id,
        subject_code,
        subject_name,
        day_of_week,
        LEFT(start_time::text, 5) AS start_time,
        LEFT(end_time::text, 5) AS end_time,
        room,
        capacity,
        enrolled_students,
        available_slots
      FROM available_schedules
      ORDER BY subject_code, schedule_id
    ''');

    return result.map((row) {
      return AvailableSchedule.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> enrollStudent(int studentId, int scheduleId) async {
    final connection = await DBConnection.connect();

    await connection.execute(
      Sql.named('''
        INSERT INTO enrollments (
          student_id,
          schedule_id,
          status
        )
        VALUES (
          @student_id,
          @schedule_id,
          'Enrolled'
        )
      '''),
      parameters: {'student_id': studentId, 'schedule_id': scheduleId},
    );
  }

  Future<void> changeSchedule(int enrollmentId, int scheduleId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        UPDATE enrollments e
        SET schedule_id = @schedule_id
        WHERE e.enrollment_id = @enrollment_id
          AND e.status = 'Enrolled'
          AND EXISTS (
            SELECT 1
            FROM schedules old_sc
            JOIN schedules new_sc
              ON old_sc.subject_id = new_sc.subject_id
            WHERE old_sc.schedule_id = e.schedule_id
              AND new_sc.schedule_id = @schedule_id
          )
      '''),
      parameters: {'enrollment_id': enrollmentId, 'schedule_id': scheduleId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Enrollment not found or invalid subject.');
    }
  }

  Future<void> dropEnrollment(int enrollmentId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        UPDATE enrollments
        SET status = 'Dropped'
        WHERE enrollment_id = @enrollment_id
          AND status = 'Enrolled'
      '''),
      parameters: {'enrollment_id': enrollmentId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Active enrollment not found.');
    }
  }

  Future<void> deleteEnrollment(int enrollmentId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        DELETE FROM enrollments
        WHERE enrollment_id = @enrollment_id
          AND status = 'Dropped'
      '''),
      parameters: {'enrollment_id': enrollmentId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Drop the enrollment before deleting it.');
    }
  }
}
