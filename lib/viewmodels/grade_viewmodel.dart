import 'package:flutter/foundation.dart';
import '../models/grade.dart';
import '../models/enrollment.dart';
import '../repositories/grade_repository.dart';

class GradeViewModel extends ChangeNotifier {
  final GradeRepository _repository = GradeRepository();

  List<Grade> grades = [];
  List<Enrollment> enrollments = [];

  bool isLoading = false;
  bool isSaving = false;
  bool _disposed = false;

  String? errorMessage;
  int? selectedStudentId;

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

  List<Grade> get visibleGrades {
    return grades.where((grade) {
      return selectedStudentId == null || grade.studentId == selectedStudentId;
    }).toList();
  }

  List<Enrollment> get ungradedEnrollments {
    final gradedIds = grades.map((grade) => grade.enrollmentId).toSet();

    return enrollments.where((enrollment) {
      return !gradedIds.contains(enrollment.enrollmentId);
    }).toList();
  }

  int get passedCount {
    return visibleGrades.where((grade) => grade.isPassed).length;
  }

  int get failedCount {
    return visibleGrades.where((grade) => !grade.isPassed).length;
  }

  double get averageGrade {
    final records = visibleGrades;

    if (records.isEmpty) {
      return 0;
    }

    final total = records.fold<double>(0, (sum, item) => sum + item.grade);

    return total / records.length;
  }

  void filterStudent(int? studentId) {
    selectedStudentId = studentId;
    notifyListeners();
  }

  Future<void> loadGrades() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      grades = await _repository.getGrades();

      enrollments = await _repository.getActiveEnrollments();

      if (selectedStudentId != null &&
          !grades.any((g) => g.studentId == selectedStudentId) &&
          !enrollments.any((e) => e.studentId == selectedStudentId)) {
        selectedStudentId = null;
      }
    } catch (_) {
      errorMessage = 'Unable to load grade records.';
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
      await loadGrades();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> saveGrade(Grade grade) {
    return _write(() async {
      if (!grade.grade.isFinite || grade.grade < 0 || grade.grade > 100) {
        throw StateError('Grade must be between 0 and 100.');
      }

      if (grade.gradeId == null) {
        await _repository.addGrade(grade);
      } else {
        await _repository.updateGrade(grade);
      }
    });
  }

  Future<void> deleteGrade(int gradeId) {
    return _write(() => _repository.deleteGrade(gradeId));
  }

  String getErrorMessage(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('active enrollment') ||
        text.contains('enrollment not found')) {
      return 'Cannot assign a grade without '
          'an active enrollment.';
    }

    if (text.contains('duplicate key') || text.contains('unique constraint')) {
      return 'A grade already exists '
          'for this enrollment.';
    }

    if (text.contains('between 0 and 100')) {
      return 'Grade must be between 0 and 100.';
    }

    return 'Unable to save grade. '
        'Check the information and connection.';
  }
}
