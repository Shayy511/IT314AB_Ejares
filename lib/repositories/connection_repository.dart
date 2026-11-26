import '../core/db_connection.dart';

class ConnectionRepository {
  Future<String> testConnection() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('SELECT current_database()');

    return result.first[0].toString();
  }

  Future<int> getStudentCount() async {
    final connection = await DBConnection.connect();

    final result = await connection.execute('SELECT COUNT(*) FROM students');

    return int.parse(result.first[0].toString());
  }
}
