import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enrollment.dart';
import '../viewmodels/enrollment_viewmodel.dart';
import 'enrollment_form_screen.dart';

class EnrollmentListScreen extends StatelessWidget {
  const EnrollmentListScreen({super.key});

  static const accents = [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  void showForm(BuildContext context, {Enrollment? enrollment}) {
    final vm = context.read<EnrollmentViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: EnrollmentFormScreen(enrollment: enrollment),
        ),
      ),
    );
  }

  Future<void> confirmAction(
    BuildContext context,
    Enrollment enrollment, {
    required bool delete,
  }) async {
    final vm = context.read<EnrollmentViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(delete ? 'Delete Enrollment' : 'Drop Enrollment'),
        content: Text(
          delete
              ? 'Permanently delete this enrollment?'
              : 'Drop ${enrollment.subjectCode} '
                    'for ${enrollment.studentName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(delete ? 'Delete' : 'Drop'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      if (delete) {
        await vm.delete(enrollment.enrollmentId);
      } else {
        await vm.drop(enrollment.enrollmentId);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Change saved, but reload failed.'
                : delete
                ? 'Enrollment deleted.'
                : 'Subject dropped successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to complete the operation. '
            'The enrollment may have related records.',
          ),
        ),
      );
    }
  }

  Widget infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EnrollmentViewModel>();
    final busy = vm.isLoading || vm.isSaving;
    final enrollments = vm.visibleEnrollments;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Enrollment Management',
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
            tooltip: 'Reload enrollments',
            onPressed: busy ? null : vm.loadEnrollments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy || vm.errorMessage != null
            ? null
            : () => showForm(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Enroll Student'),
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
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_ind,
                        size: 65,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Student Enrollments',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Enrolled: ${vm.activeCount}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        'Dropped: ${vm.droppedCount}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SwitchListTile(
              title: const Text('Show dropped enrollments'),
              value: vm.showDropped,
              onChanged: (_) => vm.toggleDropped(),
            ),

            Expanded(
              child: buildEnrollmentList(context, vm, enrollments, busy),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEnrollmentList(
    BuildContext context,
    EnrollmentViewModel vm,
    List<Enrollment> enrollments,
    bool busy,
  ) {
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
              onPressed: vm.loadEnrollments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (enrollments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.deepPurple),
            SizedBox(height: 12),
            Text('No enrollments found.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = enrollments[index];
        final color = accents[index % accents.length];

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
                  radius: 28,
                  backgroundColor: color.shade100,
                  child: Icon(Icons.person, color: color.shade700),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        enrollment.studentName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color.shade700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: enrollment.isEnrolled
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          enrollment.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: enrollment.isEnrolled
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),

                      const Divider(),

                      infoRow(
                        Icons.badge_outlined,
                        'ID: ${enrollment.schoolId ?? enrollment.studentId}',
                        color,
                      ),

                      infoRow(
                        Icons.menu_book,
                        '${enrollment.subjectCode} - '
                        '${enrollment.subjectName}',
                        color,
                      ),

                      infoRow(
                        Icons.calendar_today,
                        enrollment.dayOfWeek,
                        color,
                      ),

                      infoRow(
                        Icons.access_time,
                        '${enrollment.startTime} - '
                        '${enrollment.endTime}',
                        color,
                      ),

                      infoRow(
                        Icons.meeting_room,
                        'Room: ${enrollment.room}',
                        color,
                      ),

                      infoRow(
                        Icons.event_note,
                        'Enrollment Date: '
                        '${enrollment.enrollmentDate.split(" ").first}',
                        color,
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    if (enrollment.isEnrolled) ...[
                      IconButton(
                        tooltip: 'Change Schedule',
                        onPressed: busy
                            ? null
                            : () => showForm(context, enrollment: enrollment),
                        icon: const Icon(
                          Icons.edit_calendar,
                          color: Colors.blue,
                        ),
                      ),

                      IconButton(
                        tooltip: 'Drop Subject',
                        onPressed: busy
                            ? null
                            : () => confirmAction(
                                context,
                                enrollment,
                                delete: false,
                              ),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ] else
                      IconButton(
                        tooltip: 'Delete Enrollment',
                        onPressed: busy
                            ? null
                            : () => confirmAction(
                                context,
                                enrollment,
                                delete: true,
                              ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
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
