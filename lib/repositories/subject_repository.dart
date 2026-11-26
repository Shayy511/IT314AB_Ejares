import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/subject.dart';

class SubjectRepository {
  Future<List<Subject>> getSubjects() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT subject_id,
             subject_code,
             subject_name,
             units
      FROM subjects
      ORDER BY subject_code
    ''');

    return result.map((row) {
      return Subject.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> addSubject(Subject subject) async {
    final connection = await DBConnection.connect();

    await connection.execute(
      Sql.named('''
        INSERT INTO subjects (
          subject_code,
          subject_name,
          units
        )
        VALUES (
          @subject_code,
          @subject_name,
          @units
        )
      '''),
      parameters: subject.toMap(),
    );
  }

  Future<void> updateSubject(Subject subject) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        UPDATE subjects
        SET subject_code = @subject_code,
            subject_name = @subject_name,
            units = @units
        WHERE subject_id = @subject_id
      '''),
      parameters: {...subject.toMap(), 'subject_id': subject.subjectId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Subject not found.');
    }
  }

  Future<void> deleteSubject(int subjectId) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        DELETE FROM subjects
        WHERE subject_id = @subject_id
      '''),
      parameters: {'subject_id': subjectId},
    );

    if (result.affectedRows == 0) {
      throw StateError('Subject not found.');
    }
  }
}
