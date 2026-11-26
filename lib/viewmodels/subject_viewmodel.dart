import 'package:flutter/foundation.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

class SubjectViewModel extends ChangeNotifier {
  final SubjectRepository _repository = SubjectRepository();

  List<Subject> subjects = [];

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadSubjects() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      subjects = await _repository.getSubjects();
    } catch (e) {
      errorMessage = 'Unable to load subjects.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSubject(Subject subject) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait.');
    }

    isSaving = true;
    notifyListeners();

    try {
      if (subject.subjectId == null) {
        await _repository.addSubject(subject);
      } else {
        await _repository.updateSubject(subject);
      }

      await loadSubjects();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteSubject(int subjectId) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait.');
    }

    isSaving = true;
    notifyListeners();

    try {
      await _repository.deleteSubject(subjectId);
      await loadSubjects();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
