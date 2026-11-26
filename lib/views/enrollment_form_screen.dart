import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enrollment.dart';
import '../viewmodels/enrollment_viewmodel.dart';

class EnrollmentFormScreen extends StatefulWidget {
  final Enrollment? enrollment;

  const EnrollmentFormScreen({super.key, this.enrollment});

  @override
  State<EnrollmentFormScreen> createState() => _EnrollmentFormScreenState();
}

class _EnrollmentFormScreenState extends State<EnrollmentFormScreen> {
  final formKey = GlobalKey<FormState>();

  int? studentId;
  int? subjectId;
  int? scheduleId;

  bool saving = false;
  String? error;

  bool get isEditing => widget.enrollment != null;

  @override
  void initState() {
    super.initState();

    final vm = context.read<EnrollmentViewModel>();

    studentId = widget.enrollment?.studentId;
    scheduleId = widget.enrollment?.scheduleId;

    for (final schedule in vm.schedules) {
      if (schedule.scheduleId == scheduleId) {
        subjectId = schedule.subjectId;
        break;
      }
    }
  }

  Future<void> saveEnrollment() async {
    if (saving || !formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<EnrollmentViewModel>();

    setState(() {
      saving = true;
      error = null;
    });

    try {
      if (isEditing) {
        await vm.changeSchedule(widget.enrollment!.enrollmentId, scheduleId!);
      } else {
        await vm.enroll(studentId!, scheduleId!);
      }

      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Enrollment saved, but reload failed.'
                : isEditing
                ? 'Schedule changed successfully.'
                : 'Student enrolled successfully!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = vm.getErrorMessage(e);
      });
    } finally {
      if (mounted && saving) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EnrollmentViewModel>();

    final subjectOptions = <int, String>{};

    for (final schedule in vm.schedules) {
      subjectOptions[schedule.subjectId] =
          '${schedule.subjectCode} - '
          '${schedule.subjectName}';
    }

    final scheduleOptions = vm.schedules
        .where((schedule) => schedule.subjectId == subjectId)
        .toList();

    AvailableSchedule? selectedSchedule;

    for (final schedule in scheduleOptions) {
      if (schedule.scheduleId == scheduleId) {
        selectedSchedule = schedule;
        break;
      }
    }

    final selected = selectedSchedule;

    final full =
        selected != null &&
        selected.availableSlots <= 0 &&
        selected.scheduleId != widget.enrollment?.scheduleId;

    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Change Schedule' : 'Enroll Student'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 550,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.assignment_ind,
                      size: 76,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      isEditing ? 'Change Schedule' : 'Student Enrollment',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Select the student, subject, '
                      'and class schedule.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    DropdownButtonFormField<int>(
                      initialValue:
                          vm.students.any((s) => s.studentId == studentId)
                          ? studentId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                      ),
                      items: vm.students.map((student) {
                        return DropdownMenuItem<int>(
                          value: student.studentId!,
                          child: Text(
                            '${student.studentName} '
                            '(${student.displayId})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: saving || isEditing
                          ? null
                          : (value) {
                              setState(() {
                                studentId = value;
                                error = null;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Select a student';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: subjectOptions.containsKey(subjectId)
                          ? subjectId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: subjectOptions.entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: saving || isEditing
                          ? null
                          : (value) {
                              setState(() {
                                subjectId = value;
                                scheduleId = null;
                                error = null;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Select a subject';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      key: ValueKey(subjectId),
                      initialValue: selected?.scheduleId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Schedule',
                        border: OutlineInputBorder(),
                      ),
                      items: scheduleOptions.map((schedule) {
                        return DropdownMenuItem<int>(
                          value: schedule.scheduleId,
                          child: Text(
                            '${schedule.dayOfWeek} '
                            '${schedule.startTime} - '
                            '${schedule.endTime} '
                            '(${schedule.room})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: saving || scheduleOptions.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                scheduleId = value;
                                error = null;
                              });
                            },
                      validator: (value) {
                        if (value == null) {
                          return 'Select a schedule';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    if (selected != null)
                      Card(
                        elevation: 3,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Schedule Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),

                                const Divider(),

                                Text('Subject: ${selected.subjectName}'),

                                const SizedBox(height: 8),

                                Text('Day: ${selected.dayOfWeek}'),

                                const SizedBox(height: 8),

                                Text(
                                  'Time: ${selected.startTime}'
                                  ' - ${selected.endTime}',
                                ),

                                const SizedBox(height: 8),

                                Text('Room: ${selected.room}'),

                                const SizedBox(height: 8),

                                Text('Capacity: ${selected.capacity}'),

                                const SizedBox(height: 8),

                                Text('Enrolled: ${selected.enrolledStudents}'),

                                const SizedBox(height: 12),

                                LinearProgressIndicator(
                                  value:
                                      (selected.enrolledStudents /
                                              selected.capacity)
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                  color: full ? Colors.red : Colors.deepPurple,
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'Available Slots: '
                                  '${selected.availableSlots}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: full ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (full)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'No available slots remaining.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    if (saving)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: full || vm.isSaving || vm.isLoading
                              ? null
                              : saveEnrollment,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            isEditing ? 'Save Schedule' : 'Enroll Student',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
