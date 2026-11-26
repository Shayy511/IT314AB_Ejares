import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../models/subject.dart';
import '../repositories/schedule_repository.dart';
import '../repositories/subject_repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _repository = ScheduleRepository();

  final SubjectRepository _subjectRepository = SubjectRepository();

  List<Schedule> schedules = [];
  List<Subject> subjects = [];

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Future<void> loadSchedules() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      schedules = await _repository.getSchedules();
      subjects = await _subjectRepository.getSubjects();
    } catch (_) {
      errorMessage = 'Unable to load schedules.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSchedule(Schedule schedule) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait.');
    }

    isSaving = true;
    notifyListeners();

    try {
      if (schedule.scheduleId == null) {
        await _repository.addSchedule(schedule);
      } else {
        await _repository.updateSchedule(schedule);
      }

      await loadSchedules();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    if (isSaving || isLoading) {
      throw StateError('Please wait.');
    }

    isSaving = true;
    notifyListeners();

    try {
      await _repository.deleteSchedule(scheduleId);
      await loadSchedules();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
