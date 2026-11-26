import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';

class SubjectFormScreen extends StatefulWidget {
  final Subject? subject;

  const SubjectFormScreen({super.key, this.subject});

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController codeController;
  late final TextEditingController nameController;
  late final TextEditingController unitsController;

  bool saving = false;

  bool get isEditing => widget.subject != null;

  @override
  void initState() {
    super.initState();

    codeController = TextEditingController(
      text: widget.subject?.subjectCode ?? '',
    );

    nameController = TextEditingController(
      text: widget.subject?.subjectName ?? '',
    );

    unitsController = TextEditingController(
      text: widget.subject?.units.toString() ?? '',
    );
  }

  @override
  void dispose() {
    codeController.dispose();
    nameController.dispose();
    unitsController.dispose();
    super.dispose();
  }

  Future<void> saveSubject() async {
    if (saving || !_formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<SubjectViewModel>();

    setState(() => saving = true);

    try {
      final subject = Subject(
        subjectId: widget.subject?.subjectId,
        subjectCode: codeController.text.trim().toUpperCase(),
        subjectName: nameController.text.trim(),
        units: int.parse(unitsController.text.trim()),
      );

      await vm.saveSubject(subject);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage != null
                ? 'Subject saved, but list reload failed.'
                : isEditing
                ? 'Subject updated successfully.'
                : 'Subject added successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save subject. '
            'Check the subject code and connection.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubjectViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Subject' : 'Add Subject')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 480,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.menu_book,
                    size: 76,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 18),

                  Text(
                    isEditing ? 'Edit Subject' : 'Add Subject',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isEditing
                        ? 'Update the subject information.'
                        : 'Fill in the details to add a new subject.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: codeController,
                    enabled: !saving,
                    decoration: const InputDecoration(
                      labelText: 'Subject Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final code = value?.trim().toUpperCase() ?? '';

                      if (code.isEmpty) {
                        return 'This field is required';
                      }

                      if (code.length > 20) {
                        return 'Maximum 20 characters';
                      }

                      final duplicate = vm.subjects.any(
                        (subject) =>
                            subject.subjectCode.toUpperCase() == code &&
                            subject.subjectId != widget.subject?.subjectId,
                      );

                      if (duplicate) {
                        return 'Subject code already exists';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nameController,
                    enabled: !saving,
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }

                      if (value.trim().length > 150) {
                        return 'Maximum 150 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: unitsController,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Units',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final units = int.tryParse(value?.trim() ?? '');

                      if (units == null || units <= 0 || units > 2147483647) {
                        return 'Enter valid subject units';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  if (saving)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: vm.isLoading || vm.isSaving
                            ? null
                            : saveSubject,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(isEditing ? 'Save Changes' : 'Add Subject'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
