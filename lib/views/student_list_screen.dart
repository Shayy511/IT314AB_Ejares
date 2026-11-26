import 'student_academic_records.dart';
import '../viewmodels/grade_viewmodel.dart';
import 'grade_list_screen.dart';
import '../viewmodels/enrollment_viewmodel.dart';
import 'enrollment_list_screen.dart';
import '../viewmodels/subject_viewmodel.dart';
import 'subject_list_screen.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'schedule_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../viewmodels/student_viewmodel.dart';

const logo = 'assets/DBTC-_School_Logo.png';

const gradient = LinearGradient(colors: [Color(0xFF4527A0), Color(0xFFD84315)]);

const pageGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFEDE7F6)],
);

void message(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Widget avatar(Student student, Color color, {double radius = 30}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: color.withAlpha(35),
    child: ClipOval(
      child: Image.asset(
        student.imagePath ?? logo,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Icon(Icons.person, size: radius, color: color);
        },
      ),
    ),
  );
}

Future<void> flag(
  BuildContext context,
  StudentViewModel vm,
  Student student,
  bool favorite,
) async {
  try {
    await vm.flag(student, favorite);
  } catch (_) {
    if (context.mounted) {
      message(context, 'Unable to update student.');
    }
  }
}

Future<void> edit(BuildContext context, Student student) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Edit Student'),
      content: SizedBox(width: 430, child: StudentForm(student: student)),
    ),
  );
}

Future<void> remove(
  BuildContext context,
  StudentViewModel vm,
  Student student, {
  bool details = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Student'),
      content: Text(
        'Are you sure you want to delete '
        '${student.studentName}?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext, false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext, true);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  try {
    await vm.delete(student.studentId!);

    if (context.mounted) {
      message(context, 'Student deleted.');

      if (details) {
        Navigator.pop(context);
      }
    }
  } catch (_) {
    if (context.mounted) {
      message(
        context,
        'Unable to delete student. '
        'The student may have related records.',
      );
    }
  }
}

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  static const accents = [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  Widget infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();
    final students = vm.visible;
    final busy = vm.isLoading || vm.isSaving;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4527A0), Color(0xFFD84315)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/DBTC-_School_Logo.png', height: 70),
                  const SizedBox(height: 10),
                  const Text(
                    'Enrollment System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.people, color: Colors.deepPurple),
              title: const Text('Student Management'),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
              title: const Text('Subject Management'),
              onTap: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => SubjectViewModel()..loadSubjects(),
                      child: const SubjectListScreen(),
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
                color: Colors.deepPurple,
              ),
              title: const Text('Schedule Management'),
              onTap: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => ScheduleViewModel()..loadSchedules(),
                      child: const ScheduleListScreen(),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.deepPurple),
              title: const Text('Enrollment Management'),
              onTap: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => EnrollmentViewModel()..loadEnrollments(),
                      child: const EnrollmentListScreen(),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.grade, color: Colors.deepPurple),
              title: const Text('Grades Management'),
              onTap: () {
                final navigator = Navigator.of(context);

                navigator.pop();

                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => GradeViewModel()..loadGrades(),
                      child: const GradeListScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'My First Flutter Application',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: gradient),
        ),
        actions: [
          IconButton(
            tooltip: 'Reload students',
            onPressed: busy ? null : vm.loadStudents,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sort A to Z',
            onPressed: vm.toggleSort,
            icon: const Icon(Icons.sort_by_alpha),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy || vm.errorMessage != null
            ? null
            : () {
                Navigator.pushNamed(context, '/add-student');
              },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: pageGradient),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(gradient: gradient),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          logo,
                          width: 160,
                          height: 160,
                          errorBuilder: (_, _, _) {
                            return const Icon(Icons.school, size: 100);
                          },
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Don Bosco Technical College - Cebu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 12),
                        Divider(color: Colors.deepPurple, thickness: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${students.length} students',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SwitchListTile(
              title: const Text('Show all database students'),
              subtitle: Text('${vm.students.length} total database records'),
              value: vm.showAll,
              onChanged: (_) => vm.toggleAll(),
            ),

            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading student directory...'),
                    ],
                  ),
                ),
              )
            else if (vm.errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(vm.errorMessage!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: vm.loadStudents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Active: '
                  '${students.where((s) => s.isActive).length}'
                  '   Inactive: '
                  '${students.where((s) => !s.isActive).length}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (students.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(height: 12),
                        Text('No students found.'),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final color = accents[index % accents.length];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      color: Colors.white,
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: busy
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  '/student-details',
                                  arguments: student.studentId,
                                );
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: color, width: 7),
                            ),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [color.shade300, color.shade700],
                                  ),
                                ),
                                child: avatar(student, color),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.studentName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: color.shade700,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: student.isActive
                                            ? Colors.green.shade100
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        student.isActive
                                            ? 'Active'
                                            : 'Inactive',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: student.isActive
                                              ? Colors.green.shade800
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                    ),

                                    if (student.isFavorite)
                                      const Text(
                                        '♥ Favorite',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    if (!student.isActive)
                                      const Text(
                                        '⚠ This student is inactive',
                                        style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 12,
                                        ),
                                      ),

                                    const SizedBox(height: 6),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.shade50,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${student.course}'
                                        '${student.age == null ? "" : " • Age ${student.age}"}',
                                        style: TextStyle(
                                          color: color.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    if (student.hobby != null)
                                      Text('Hobby: ${student.hobby}'),

                                    if (student.height != null)
                                      Text('Height: ${student.height} cm'),

                                    Divider(color: color.shade100),

                                    infoRow(
                                      Icons.badge_outlined,
                                      'ID: ${student.displayId}',
                                      color,
                                    ),

                                    if (student.email != null)
                                      infoRow(
                                        Icons.email_outlined,
                                        'Email: ${student.email}',
                                        color,
                                      ),

                                    if (student.favoriteSubject != null)
                                      infoRow(
                                        Icons.menu_book_outlined,
                                        'Favorite subject: '
                                        '${student.favoriteSubject}',
                                        color,
                                      ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    tooltip: 'Change Active Status',
                                    onPressed: busy
                                        ? null
                                        : () =>
                                              flag(context, vm, student, false),
                                    icon: Icon(
                                      student.isActive
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      color: student.isActive
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: 'Favorite',
                                    onPressed: busy
                                        ? null
                                        : () =>
                                              flag(context, vm, student, true),
                                    icon: Icon(
                                      student.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: busy
                                        ? null
                                        : () => edit(context, student),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),

                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: busy
                                        ? null
                                        : () => remove(context, vm, student),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class StudentDetailsScreen extends StatelessWidget {
  final int studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();

    final matches = vm.students.where(
      (student) => student.studentId == studentId,
    );

    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Details')),
        body: const Center(child: Text('Student not found.')),
      );
    }

    final student = matches.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Student Details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              avatar(student, Colors.deepPurple, radius: 52),

              const SizedBox(height: 16),

              Text(
                student.studentName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student ID: ${student.displayId}'),
                      const SizedBox(height: 8),
                      Text('Course: ${student.course}'),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${student.isActive ? "Active" : "Inactive"}',
                      ),
                      const SizedBox(height: 8),
                      Text('Age: ${student.age ?? "Not provided"}'),
                      const SizedBox(height: 8),
                      Text('Hobby: ${student.hobby ?? "Not provided"}'),
                      const SizedBox(height: 8),
                      Text(
                        'Height: ${student.height == null ? "Not provided" : "${student.height} cm"}',
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${student.email ?? "Not provided"}'),
                      const SizedBox(height: 8),
                      Text(
                        'Favorite subject: '
                        '${student.favoriteSubject ?? "Not provided"}',
                      ),
                      const SizedBox(height: 8),
                      Text('Favorite: ${student.isFavorite ? "Yes" : "No"}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (student.studentId != null)
                StudentAcademicRecords(studentId: student.studentId!),

              const SizedBox(height: 24),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: vm.isSaving || vm.isLoading
                    ? null
                    : () => edit(context, student),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Student'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: vm.isSaving || vm.isLoading
                    ? null
                    : () => remove(context, vm, student, details: true),
                icon: const Icon(Icons.delete),
                label: const Text('Delete Student'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 480,
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 76,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 18),

                const Text(
                  'Add Student',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Fill in the details to add a new student.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                const StudentForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentForm extends StatefulWidget {
  final Student? student;

  const StudentForm({super.key, this.student});

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final formKey = GlobalKey<FormState>();

  late final Map<String, TextEditingController> fields;

  int? program;
  String? image;
  late bool active;
  bool saving = false;

  bool get isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();

    final student = widget.student;

    fields = {
      'Student ID': TextEditingController(text: student?.schoolId ?? ''),
      'Full Name': TextEditingController(text: student?.studentName ?? ''),
      'Year Level': TextEditingController(
        text: student?.yearLevel?.toString() ?? '',
      ),
      'Email Address': TextEditingController(text: student?.email ?? ''),
      'Age': TextEditingController(text: student?.age?.toString() ?? ''),
      'Hobby': TextEditingController(text: student?.hobby ?? ''),
      'Height (cm)': TextEditingController(
        text: student?.height?.toString() ?? '',
      ),
      'Favorite Subject': TextEditingController(
        text: student?.favoriteSubject ?? '',
      ),
    };

    program = student?.programId;
    image = student?.imagePath;
    active = student?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }

    super.dispose();
  }

  String? val(String name) {
    final text = fields[name]!.text.trim();

    return text.isEmpty ? null : text;
  }

  Widget field(
    String name, {
    bool requiredField = false,
    bool integer = false,
    bool decimal = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: fields[name],
        enabled: enabled && !saving,
        decoration: InputDecoration(
          labelText: name,
          border: const OutlineInputBorder(),
        ),
        keyboardType: integer || decimal
            ? TextInputType.numberWithOptions(decimal: decimal)
            : name == 'Email Address'
            ? TextInputType.emailAddress
            : TextInputType.text,
        validator: (value) {
          final text = value?.trim() ?? '';

          if (text.isEmpty) {
            return requiredField ? 'This field is required' : null;
          }

          if (integer) {
            final number = int.tryParse(text);

            if (number == null || number <= 0 || number > 2147483647) {
              return 'Enter a valid positive number';
            }
          }

          if (decimal) {
            final number = double.tryParse(text);

            if (number == null ||
                !number.isFinite ||
                number <= 0 ||
                number >= 10000) {
              return 'Enter a valid height';
            }
          }

          if (name == 'Email Address') {
            final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

            if (!emailPattern.hasMatch(text)) {
              return 'Enter a valid email address';
            }
          }

          if (name == 'Student ID') {
            if (text.length > 30) {
              return 'Maximum 30 characters';
            }

            final vm = context.read<StudentViewModel>();

            final duplicate = vm.students.any(
              (student) =>
                  student.schoolId == text &&
                  student.studentId != widget.student?.studentId,
            );

            if (duplicate) {
              return 'Student ID already exists';
            }
          }

          return null;
        },
      ),
    );
  }

  Future<void> save() async {
    if (saving || !formKey.currentState!.validate()) {
      return;
    }

    final vm = context.read<StudentViewModel>();
    final oldStudent = widget.student;

    setState(() => saving = true);

    try {
      await vm.save(
        Student(
          studentId: oldStudent?.studentId,
          schoolId: val('Student ID'),
          studentName: val('Full Name')!,
          programId: program,
          yearLevel: int.tryParse(val('Year Level') ?? ''),
          email: val('Email Address'),
          age: int.tryParse(val('Age') ?? ''),
          hobby: val('Hobby'),
          height: double.tryParse(val('Height (cm)') ?? ''),
          favoriteSubject: val('Favorite Subject'),
          imagePath: image ?? logo,
          isActive: active,
          isFavorite: oldStudent?.isFavorite ?? false,
        ),
      );

      if (!mounted) return;

      message(
        context,
        vm.errorMessage != null
            ? 'Student saved, but unable to reload records.'
            : isEditing
            ? 'Student updated successfully.'
            : 'Student added successfully.',
      );

      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Unable to save student. '
          'Check the student ID, program, '
          'and database connection.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentViewModel>();

    final images = [
      logo,
      'assets/Meee.png',
      'assets/Pal.png',
      'assets/Leila.png',
      'assets/Kuya.png',
      'assets/Therese.png',
      'assets/ZION.jpg',
    ];

    if (image != null && !images.contains(image)) {
      images.add(image!);
    }

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Student ID: ${widget.student!.displayId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            field(
              'Student ID',
              requiredField: !isEditing,
              enabled: !isEditing || widget.student!.schoolId == null,
            ),

            field('Full Name', requiredField: true),

            DropdownButtonFormField<int>(
              initialValue: vm.programs.any((p) => p.programId == program)
                  ? program
                  : null,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              items: vm.programs.map((p) {
                return DropdownMenuItem<int>(
                  value: p.programId,
                  child: Text(p.programCode),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      setState(() {
                        program = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'This field is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            field('Year Level', requiredField: !isEditing, integer: true),

            field('Email Address', requiredField: !isEditing),

            field('Age', integer: true),

            field('Hobby'),

            field('Height (cm)', decimal: true),

            field('Favorite Subject'),

            DropdownButtonFormField<String>(
              initialValue: image ?? logo,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Profile Picture',
                border: OutlineInputBorder(),
              ),
              items: images.map((path) {
                return DropdownMenuItem<String>(
                  value: path,
                  child: Text(path.split('/').last),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      setState(() {
                        image = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Active'),
              value: active,
              onChanged: saving
                  ? null
                  : (value) {
                      setState(() {
                        active = value;
                      });
                    },
            ),

            const SizedBox(height: 12),

            if (saving)
              const CircularProgressIndicator()
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: vm.isSaving || vm.isLoading ? null : save,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isEditing ? 'Save' : 'Add Student'),
                ),
              ),

            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
