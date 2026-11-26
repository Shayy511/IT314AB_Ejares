import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/program.dart';
import '../repositories/student_repository.dart';

class StudentViewModel extends ChangeNotifier {
  final StudentRepository _repository = StudentRepository();

  List<Student> students = [];
  List<Program> programs = [];

  bool isLoading = false;
  bool isSaving = false;
  bool sorted = false;
  bool showAll = false;

  String? errorMessage;

  List<Student> get visible {
    final items = students.where((student) {
      return showAll || student.schoolId != null;
    }).toList();

    if (sorted) {
      items.sort(
        (a, b) =>
            a.studentName.toLowerCase().compareTo(b.studentName.toLowerCase()),
      );
    }

    return items;
  }

  void toggleSort() {
    sorted = !sorted;
    notifyListeners();
  }

  void toggleAll() {
    showAll = !showAll;
    notifyListeners();
  }

  Future<void> loadStudents() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      students = await _repository.getStudents();
      programs = await _repository.getPrograms();
    } catch (e) {
      errorMessage = 'Unable to load database records.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _write(Future<void> Function() action) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait for the current operation.');
    }

    isSaving = true;
    notifyListeners();

    try {
      await action();
      await loadStudents();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> save(Student student) {
    return _write(() => _repository.save(student));
  }

  Future<void> delete(int id) {
    return _write(() => _repository.deleteStudent(id));
  }

  Future<void> flag(Student student, bool favorite) {
    return _write(
      () => _repository.setFlag(
        student.studentId!,
        favorite ? !student.isFavorite : !student.isActive,
        favorite: favorite,
      ),
    );
  }
}
