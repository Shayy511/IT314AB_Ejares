import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grade.dart';
import '../viewmodels/grade_viewmodel.dart';
import 'grade_form_screen.dart';

class GradeListScreen extends StatelessWidget {
  const GradeListScreen({super.key});

  void showForm(BuildContext context, {Grade? grade}) {
    final vm = context.read<GradeViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: GradeFormScreen(grade: grade),
        ),
      ),
    );
  }

  Future<void> deleteGrade(BuildContext context, Grade grade) async {
    final vm = context.read<GradeViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Grade'),
        content: Text(
          'Delete the grade for '
          '${grade.studentName} in '
          '${grade.subjectCode}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await vm.deleteGrade(grade.gradeId!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Grade deleted, but reload failed.'
                : 'Grade deleted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to delete grade.')));
    }
  }

  Widget summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GradeViewModel>();

    final busy = vm.isLoading || vm.isSaving;

    final students = <int, String>{};

    for (final enrollment in vm.enrollments) {
      students[enrollment.studentId] = enrollment.studentName;
    }

    for (final grade in vm.grades) {
      if (grade.studentId != null) {
        students[grade.studentId!] = grade.studentName ?? 'Unknown';
      }
    }

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Grades Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4527A0), Color(0xFFD84315)],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload grades',
            onPressed: busy ? null : vm.loadGrades,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy || vm.errorMessage != null
            ? null
            : () => showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Grade'),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFEDE7F6)],
          ),
        ),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Student Grades',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        summaryItem(
                          'Average',
                          vm.visibleGrades.isEmpty
                              ? '—'
                              : vm.averageGrade.toStringAsFixed(2),
                          Colors.deepPurple,
                        ),

                        summaryItem(
                          'Passed',
                          '${vm.passedCount}',
                          Colors.green,
                        ),

                        summaryItem('Failed', '${vm.failedCount}', Colors.red),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text('${vm.visibleGrades.length} grade records'),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonFormField<int>(
                key: ValueKey(vm.selectedStudentId),
                initialValue: vm.selectedStudentId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Filter by Student',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All Students'),
                  ),

                  ...students.entries.map(
                    (entry) => DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: busy ? null : vm.filterStudent,
              ),
            ),

            Expanded(child: buildGradeList(context, vm, busy)),
          ],
        ),
      ),
    );
  }

  Widget buildGradeList(BuildContext context, GradeViewModel vm, bool busy) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: vm.loadGrades,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.visibleGrades.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grade_outlined, size: 64, color: Colors.deepPurple),

            SizedBox(height: 12),

            Text('No grades found.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: vm.visibleGrades.length,
      itemBuilder: (context, index) {
        final grade = vm.visibleGrades[index];

        final color = grade.isPassed ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: Colors.white,
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 7)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.shade100,
                  child: Icon(
                    grade.isPassed ? Icons.check_circle : Icons.cancel,
                    color: color.shade700,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.studentName ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text('ID: ${grade.schoolId ?? grade.studentId}'),

                      const Divider(),

                      Text(
                        '${grade.subjectCode} - '
                        '${grade.subjectName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Grade: ${grade.grade.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color.shade700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          grade.remarks,
                          style: TextStyle(
                            color: color.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Enrollment: '
                        '${grade.enrollmentStatus}',
                      ),

                      Text(
                        'Date Recorded: '
                        '${grade.dateRecorded?.split(" ").first ?? ""}',
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    IconButton(
                      tooltip: 'Edit Grade',
                      onPressed: busy || grade.enrollmentStatus != 'Enrolled'
                          ? null
                          : () => showForm(context, grade: grade),
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    ),

                    IconButton(
                      tooltip: 'Delete Grade',
                      onPressed: busy
                          ? null
                          : () => deleteGrade(context, grade),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
