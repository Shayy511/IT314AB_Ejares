import 'package:postgres/postgres.dart';

class DBConnection {
  static Connection? _connection;
  static Future<Connection>? _opening;

  static Future<Connection> connect() async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }

    final pending = _opening ??= _openConnection();

    try {
      return await pending;
    } finally {
      if (identical(_opening, pending)) {
        _opening = null;
      }
    }
  }

  static Future<Connection> _openConnection() async {
    const host = String.fromEnvironment('DB_HOST');
    const port = String.fromEnvironment('DB_PORT', defaultValue: '5432');
    const database = String.fromEnvironment('DB_NAME');
    const username = String.fromEnvironment('DB_USER');
    const password = String.fromEnvironment('DB_PASSWORD');

    if (host.isEmpty ||
        database.isEmpty ||
        username.isEmpty ||
        password.isEmpty) {
      throw StateError('Database configuration is missing.');
    }

    _connection = await Connection.open(
      Endpoint(
        host: host,
        port: int.parse(port),
        database: database,
        username: username,
        password: password,
      ),
      settings: ConnectionSettings(sslMode: SslMode.verifyFull),
    );

    return _connection!;
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
