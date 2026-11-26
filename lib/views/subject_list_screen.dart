import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';
import 'subject_form_screen.dart';

class SubjectListScreen extends StatelessWidget {
  const SubjectListScreen({super.key});

  static const accents = [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  void showForm(BuildContext context, {Subject? subject}) {
    final vm = context.read<SubjectViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: SubjectFormScreen(subject: subject),
        ),
      ),
    );
  }

  Future<void> deleteSubject(BuildContext context, Subject subject) async {
    final vm = context.read<SubjectViewModel>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete '
          '${subject.subjectName}?',
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
      await vm.deleteSubject(subject.subjectId!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Subject deleted, but reload failed.'
                : 'Subject deleted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete subject. '
            'It may have related records.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubjectViewModel>();

    final busy = vm.isLoading || vm.isSaving;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Subject Management',
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
            tooltip: 'Reload subjects',
            onPressed: busy ? null : vm.loadSubjects,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy || vm.errorMessage != null
            ? null
            : () => showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
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
                        Icons.menu_book,
                        size: 65,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Available Subjects',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text('${vm.subjects.length} subjects'),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(child: buildSubjectList(context, vm, busy)),
          ],
        ),
      ),
    );
  }

  Widget buildSubjectList(
    BuildContext context,
    SubjectViewModel vm,
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
              onPressed: vm.loadSubjects,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.subjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.deepPurple),

            SizedBox(height: 12),

            Text('No subjects available.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: vm.subjects.length,
      itemBuilder: (context, index) {
        final subject = vm.subjects[index];

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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color.shade100,
                  child: Icon(Icons.menu_book, color: color.shade700),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.subjectCode,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color.shade700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subject.subjectName,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${subject.units} Units',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    IconButton(
                      tooltip: 'Edit Subject',
                      onPressed: busy
                          ? null
                          : () => showForm(context, subject: subject),
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    ),

                    IconButton(
                      tooltip: 'Delete Subject',
                      onPressed: busy
                          ? null
                          : () => deleteSubject(context, subject),
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
