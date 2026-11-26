import 'package:postgres/postgres.dart';
import '../core/db_connection.dart';
import '../models/student.dart';
import '../models/program.dart';

class StudentRepository {
  Future<List<Student>> getStudents() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT s.*, p.program_code
      FROM students s
      LEFT JOIN programs p
        ON s.program_id = p.program_id
      ORDER BY s.student_id
    ''');

    return result.map((row) {
      return Student.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<List<Program>> getPrograms() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('''
      SELECT program_id, program_code, program_name
      FROM programs
      ORDER BY program_code
    ''');

    return result.map((row) {
      return Program.fromMap(row.toColumnMap());
    }).toList();
  }

  Future<void> save(Student student) async {
    final connection = await DBConnection.connect();
    final parameters = student.toMap();

    if (student.studentId == null) {
      await connection.execute(
        Sql.named('''
          INSERT INTO students (
            student_id,
            student_name,
            school_id,
            program_id,
            year_level,
            email,
            age,
            hobby,
            height,
            favorite_subject,
            image,
            is_active,
            is_favorite
          )
          VALUES (
            nextval('directory_student_id_seq'),
            @student_name,
            @school_id,
            @program_id,
            @year_level,
            @email,
            @age,
            @hobby,
            CAST(@height AS numeric),
            @favorite_subject,
            @image,
            @is_active,
            @is_favorite
          )
        '''),
        parameters: parameters,
      );
    } else {
      final result = await connection.execute(
        Sql.named('''
          UPDATE students
          SET student_name = @student_name,
              school_id = @school_id,
              program_id = @program_id,
              year_level = @year_level,
              email = @email,
              age = @age,
              hobby = @hobby,
              height = CAST(@height AS numeric),
              favorite_subject = @favorite_subject,
              image = @image,
              is_active = @is_active,
              is_favorite = @is_favorite
          WHERE student_id = @id
        '''),
        parameters: {...parameters, 'id': student.studentId},
      );

      if (result.affectedRows == 0) {
        throw StateError('Student not found.');
      }
    }
  }

  Future<void> setFlag(int id, bool value, {required bool favorite}) async {
    final connection = await DBConnection.connect();

    await connection.execute(
      Sql.named(
        favorite
            ? '''
              UPDATE students
              SET is_favorite = @value
              WHERE student_id = @id
            '''
            : '''
              UPDATE students
              SET is_active = @value
              WHERE student_id = @id
            ''',
      ),
      parameters: {'value': value, 'id': id},
    );
  }

  Future<void> deleteStudent(int id) async {
    final connection = await DBConnection.connect();

    final result = await connection.execute(
      Sql.named('''
        DELETE FROM students
        WHERE student_id = @id
      '''),
      parameters: {'id': id},
    );

    if (result.affectedRows == 0) {
      throw StateError('Student not found.');
    }
  }
}
