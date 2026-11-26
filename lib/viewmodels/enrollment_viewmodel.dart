import 'package:flutter/foundation.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../repositories/enrollment_repository.dart';
import '../repositories/student_repository.dart';

class EnrollmentViewModel extends ChangeNotifier {
  final EnrollmentRepository _repository = EnrollmentRepository();

  final StudentRepository _studentRepository = StudentRepository();

  List<Enrollment> enrollments = [];
  List<Student> students = [];
  List<AvailableSchedule> schedules = [];

  bool isLoading = false;
  bool isSaving = false;
  bool showDropped = false;

  bool _disposed = false;

  String? errorMessage;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<Enrollment> get visibleEnrollments {
    return enrollments.where((enrollment) {
      return showDropped || enrollment.isEnrolled;
    }).toList();
  }

  int get activeCount {
    return enrollments.where((e) => e.isEnrolled).length;
  }

  int get droppedCount {
    return enrollments.where((e) => !e.isEnrolled).length;
  }

  void toggleDropped() {
    showDropped = !showDropped;
    notifyListeners();
  }

  Future<void> loadEnrollments() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      enrollments = await _repository.getEnrollments();

      students = await _studentRepository.getStudents();

      schedules = await _repository.getAvailableSchedules();
    } catch (_) {
      errorMessage = 'Unable to load enrollment records.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _write(Future<void> Function() action) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait.');
    }

    isSaving = true;
    notifyListeners();

    try {
      await action();
      await loadEnrollments();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> enroll(int studentId, int scheduleId) {
    return _write(() => _repository.enrollStudent(studentId, scheduleId));
  }

  Future<void> changeSchedule(int enrollmentId, int scheduleId) {
    return _write(() => _repository.changeSchedule(enrollmentId, scheduleId));
  }

  Future<void> drop(int enrollmentId) {
    return _write(() => _repository.dropEnrollment(enrollmentId));
  }

  Future<void> delete(int enrollmentId) {
    return _write(() => _repository.deleteEnrollment(enrollmentId));
  }

  String getErrorMessage(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('already enrolled') ||
        text.contains('unique_active_enrollment')) {
      return 'Student is already enrolled in this subject.';
    }

    if (text.contains('schedule conflict')) {
      return 'Schedule conflict detected.';
    }

    if (text.contains('no available slots')) {
      return 'No available slots remaining.';
    }

    return 'Unable to complete enrollment. '
        'Check the information and database connection.';
  }
}
