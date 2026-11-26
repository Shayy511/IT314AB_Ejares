import 'package:flutter/foundation.dart';
import '../repositories/connection_repository.dart';

class ConnectionViewModel extends ChangeNotifier {
  final ConnectionRepository _repository = ConnectionRepository();

  bool isLoading = false;
  bool isConnected = false;

  String status = 'Not connected';
  String databaseName = '';
  int studentCount = 0;

  Future<void> testConnection() async {
    if (isLoading) return;

    isLoading = true;
    isConnected = false;
    status = 'Connecting to Neon...';
    notifyListeners();

    try {
      databaseName = await _repository.testConnection();
      studentCount = await _repository.getStudentCount();

      isConnected = true;
      status = 'Database connected successfully!';
    } catch (e) {
      isConnected = false;
      status = 'Database connection failed.';

      debugPrint('Connection test error: ${e.runtimeType}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
