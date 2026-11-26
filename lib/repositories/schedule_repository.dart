import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/schedule.dart';

class ScheduleRepository {
  Future<List<Schedule>> getSchedules() async {
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
      ORDER BY
        CASE day_of_week
          WHEN 'Monday' THEN 1
          WHEN 'Tuesday' THEN 2
          WHEN 'Wednesday' THEN 3
          WHEN 'Thursday' THEN 4
          WHEN 'Friday' THEN 5
          WHEN 'Saturday' THEN 6
          WHEN 'Sunday' THEN 7
        END,
        start_time
    ''');

    return result.map((row) {
      return Schedule.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final connection = await DBConnection.connect();

    await connection.execute(
      Sql.named('''
        INSERT INTO schedules (
          subject_id,
          day_of_week,
          start_time,
          end_time,
          room,
          capacity
        )
        VALUES (
          @subject_id,
          @day_of_week,
          CAST(@start_time AS TIME),
          CAST(@end_time AS TIME),
          @room,
          @capacity
        )
      '''),
      parameters: schedule.toMap(),
    );
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        UPDATE schedules
        SET subject_id = @subject_id,
            day_of_week = @day_of_week,
            start_time = CAST(@start_time AS TIME),
            end_time = CAST(@end_time AS TIME),
            room = @room,
            capacity = @capacity
        WHERE schedule_id = @schedule_id
      '''),
      parameters: {...schedule.toMap(), 'schedule_id': schedule.scheduleId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Schedule not found.');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        DELETE FROM schedules
        WHERE schedule_id = @schedule_id
      '''),
      parameters: {'schedule_id': scheduleId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Schedule not found.');
    }
  }
}
