import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../viewmodels/grade_viewmodel.dart';

class GradeFormScreen extends StatefulWidget {
  final Grade? grade;

  const GradeFormScreen({super.key, this.grade});

  @override
  State<GradeFormScreen> createState() => _GradeFormScreenState();
}

class _GradeFormScreenState extends State<GradeFormScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController gradeController;

  int? studentId;
  int? enrollmentId;

  bool saving = false;
  String? error;

  bool get isEditing => widget.grade != null;

  @override
  void initState() {
    super.initState();

    studentId = widget.grade?.studentId;
    enrollmentId = widget.grade?.enrollmentId;

    gradeController = TextEditingController(
      text: widget.grade?.grade.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    gradeController.dispose();
    super.dispose();
  }

  Future<void> saveGrade() async {
    if (saving || !formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<GradeViewModel>();

    if (enrollmentId == null) {
      setState(() {
        error = 'Select an enrolled subject.';
      });
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      await vm.saveGrade(
        Grade(
          gradeId: widget.grade?.gradeId,
          enrollmentId: enrollmentId!,
          grade: double.parse(gradeController.text.trim()),
        ),
      );

      if (!mounted) return;

      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Grade saved, but reload failed.'
                : isEditing
                ? 'Grade updated successfully.'
                : 'Grade added successfully.',
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
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GradeViewModel>();

    final eligible = vm.ungradedEnrollments;

    final students = <int, String>{};

    for (final enrollment in eligible) {
      students[enrollment.studentId] =
          '${enrollment.studentName} '
          '(${enrollment.schoolId ?? enrollment.studentId})';
    }

    final studentEnrollments = eligible
        .where((e) => e.studentId == studentId)
        .toList();

    final enteredGrade = double.tryParse(gradeController.text.trim());

    final validGrade =
        enteredGrade != null &&
        enteredGrade.isFinite &&
        enteredGrade >= 0 &&
        enteredGrade <= 100;

    return PopScope(
      canPop: !saving,
      child: Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Grade' : 'Add Grade')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 550,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const Icon(Icons.grade, size: 76, color: Colors.deepPurple),

                    const SizedBox(height: 18),

                    Text(
                      isEditing ? 'Edit Student Grade' : 'Add Student Grade',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Assign grades to enrolled subjects.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    if (isEditing) ...[
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                          ),
                          title: Text(widget.grade!.studentName ?? ''),
                          subtitle: Text(
                            '${widget.grade!.subjectCode} - '
                            '${widget.grade!.subjectName}',
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ] else ...[
                      if (eligible.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'No eligible ungraded '
                            'enrollments available.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),

                      DropdownButtonFormField<int>(
                        initialValue: students.containsKey(studentId)
                            ? studentId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Student',
                          border: OutlineInputBorder(),
                        ),
                        items: students.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: saving
                            ? null
                            : (value) {
                                setState(() {
                                  studentId = value;
                                  enrollmentId = null;
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
                        key: ValueKey(studentId),
                        initialValue:
                            studentEnrollments.any(
                              (e) => e.enrollmentId == enrollmentId,
                            )
                            ? enrollmentId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Enrolled Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: studentEnrollments.map((enrollment) {
                          return DropdownMenuItem<int>(
                            value: enrollment.enrollmentId,
                            child: Text(
                              '${enrollment.subjectCode} - '
                              '${enrollment.subjectName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: saving || studentEnrollments.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  enrollmentId = value;
                                  error = null;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Select an enrolled subject';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: gradeController,
                      enabled: !saving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Final Grade',
                        hintText: 'Enter grade from 0 to 100',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      onChanged: (_) {
                        setState(() => error = null);
                      },
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        final grade = double.tryParse(text);

                        if (grade == null ||
                            !grade.isFinite ||
                            grade < 0 ||
                            grade > 100) {
                          return 'Enter a grade from 0 to 100';
                        }

                        if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
                          return 'Use up to two decimal places';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    if (validGrade)
                      Card(
                        color: enteredGrade >= 75
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Icon(
                                enteredGrade >= 75
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: enteredGrade >= 75
                                    ? Colors.green
                                    : Colors.red,
                                size: 36,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  enteredGrade >= 75
                                      ? 'Remarks: Passed'
                                      : 'Remarks: Failed',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: enteredGrade >= 75
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
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
                          onPressed:
                              vm.isLoading ||
                                  vm.isSaving ||
                                  (!isEditing && eligible.isEmpty)
                              ? null
                              : saveGrade,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(isEditing ? 'Save Changes' : 'Add Grade'),
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
