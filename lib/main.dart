import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 222, 66, 14),
        ),
        fontFamily: 'Georgia',
      ),
      initialRoute: '/student-list',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/student-list':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const StudentListScreen(
                title: 'My First Flutter Application',
              ),
            );
          case '/student-details':
            final student = settings.arguments;
            if (student is Profile) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => StudentDetailsScreen(profile: student),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('No student was selected')),
              ),
            );
          case '/add-student':
            return MaterialPageRoute<Profile>(
              settings: settings,
              builder: (_) => const AddStudentScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('Unknown route'))),
            );
        }
      },
    );
  }
}

enum DirectoryView { loading, students, empty }

class Profile {
  String image;
  String name;
  String courseSection;
  int age;
  String hobby;
  double height;
  String studentId;
  String email;
  String favoriteSubject;
  bool isFavorite;
  bool isActive;

  Profile({
    required this.image,
    required this.name,
    required this.courseSection,
    required this.age,
    required this.hobby,
    required this.height,
    required this.studentId,
    required this.email,
    required this.favoriteSubject,
    this.isFavorite = false,
    this.isActive = true,
  });

  // CTF 8: Turn each student into JSON for local persistence.
  Map<String, dynamic> toJson() => {
    'image': image,
    'name': name,
    'courseSection': courseSection,
    'age': age,
    'hobby': hobby,
    'height': height,
    'studentId': studentId,
    'email': email,
    'favoriteSubject': favoriteSubject,
    'isFavorite': isFavorite,
    'isActive': isActive,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    image: json['image'] as String? ?? 'assets/image/DBTC-_School_Logo.png',
    name: json['name'] as String? ?? '',
    courseSection: json['courseSection'] as String? ?? '',
    age: (json['age'] as num?)?.toInt() ?? 0,
    hobby: json['hobby'] as String? ?? 'Not specified',
    height: (json['height'] as num?)?.toDouble() ?? 0,
    studentId: json['studentId'] as String? ?? '',
    email: json['email'] as String? ?? '',
    favoriteSubject: json['favoriteSubject'] as String? ?? 'Not specified',
    isFavorite: json['isFavorite'] as bool? ?? false,
    isActive: json['isActive'] as bool? ?? true,
  );
}

// CTF 8: Save the entire directory, including edits and deletions.
class StudentLocalStorage {
  static const String _key = 'ctf8_student_directory_v1';
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static Future<List<Profile>?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null; // First launch: use original students.
    final values = jsonDecode(raw) as List<dynamic>;
    return values
        .map(
          (value) => Profile.fromJson(Map<String, dynamic>.from(value as Map)),
        )
        .toList(); // An empty saved list stays empty.
  }

  static Future<void> save(List<Profile> students) async {
    await _prefs.setString(
      _key,
      jsonEncode(students.map((student) => student.toJson()).toList()),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key, required this.title});

  final String title;

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final List<MaterialColor> accents = const [
    Colors.deepPurple,
    Colors.deepOrange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  List<Profile> profiles = createInitialProfiles();

  static List<Profile> createInitialProfiles() => [
    Profile(
      image: 'assets/image/Meee.png',
      name: 'Shairha May B. Ejares',
      courseSection: 'BSIT 3',
      age: 20,
      hobby: 'Swimming',
      height: 149.0,
      studentId: '2020-00001',
      email: 'shairha.ejares@dbtc-cebu.edu.ph',
      favoriteSubject: 'Physical Education',
    ),
    Profile(
      image: 'assets/image/Pal.png',
      isActive: false,
      name: 'Karol S. Pal',
      courseSection: 'BSIT 3',
      age: 21,
      hobby: 'Eating',
      height: 150.0,
      studentId: '2020-00002',
      email: 'karol.pal@dbtc-cebu.edu.ph',
      favoriteSubject: 'Recess',
    ),
    Profile(
      image: 'assets/image/Leila.png',
      name: 'Leila G. Bangoy',
      courseSection: 'BSIT 3',
      age: 21,
      hobby: 'Coding',
      height: 149.0,
      studentId: '2020-00003',
      email: 'leila.bangoy@dbtc-cebu.edu.ph',
      favoriteSubject: 'Math',
    ),
    Profile(
      image: 'assets/image/Kuya.png',
      name: 'Nathaneil B.Ejares',
      courseSection: 'BSCE 4',
      age: 21,
      hobby: 'Gaming',
      height: 151.0,
      studentId: '2020-00004',
      email: 'nathaneil.ejares@cit.edu.ph',
      favoriteSubject: 'Mathematics',
    ),
    Profile(
      image: 'assets/image/Therese.png',
      isActive: false,
      name: 'Therese Deanne Lumactud',
      courseSection: 'BSIT 3',
      age: 21,
      hobby: 'Reading',
      height: 149.0,
      studentId: '2020-00005',
      email: 'therese.lumactud@dbtc-cebu.edu.ph',
      favoriteSubject: 'Recess',
    ),
    Profile(
      image: 'assets/image/ZION.jpg',
      name: 'Zion Hale Zamora',
      courseSection: 'BSIT 4',
      age: 21,
      hobby: 'Reading',
      height: 160.0,
      studentId: '2020-00006',
      email: 'Zionhale.zamora@dbtc-cebu.edu.ph',
      favoriteSubject: 'English',
    ),
  ];

  bool isLoading = true;

  // CTF 8: Load saved students, or keep the original profiles on first launch.
  @override
  void initState() {
    super.initState();
    _loadSavedStudents();
  }

  Future<void> _loadSavedStudents() async {
    try {
      final saved = await StudentLocalStorage.load();
      if (!mounted) return;
      setState(() {
        if (saved != null) profiles = saved;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage('Could not load saved records');
    }
  }

  Future<void> _saveStudents() async {
    try {
      await StudentLocalStorage.save(profiles);
    } catch (_) {
      if (mounted) showMessage('Could not save student records');
    }
  }

  // CTF 8: A form returns a new Profile to the existing screen.
  Future<void> _openAddStudent() async {
    final newStudent = await Navigator.pushNamed<Profile>(
      context,
      '/add-student',
      arguments: profiles.map((profile) => profile.studentId).toList(),
    );
    if (!mounted || newStudent == null) return;
    if (profiles.any((p) => p.studentId == newStudent.studentId)) {
      showMessage('Student ID already exists');
      return;
    }
    setState(() => profiles.add(newStudent));
    await _saveStudents();
    if (mounted) showMessage('${newStudent.name} enrolled successfully');
  }

  DirectoryView get directoryView {
    if (isLoading) return DirectoryView.loading;
    if (profiles.isEmpty) return DirectoryView.empty;
    return DirectoryView.students;
  }

  bool sortedAlphabetically = false;
  String? selectedStudentId;

  void toggleSort() {
    setState(() {
      sortedAlphabetically = !sortedAlphabetically;
      if (sortedAlphabetically) {
        profiles.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      } else {
        profiles.sort((a, b) => a.studentId.compareTo(b.studentId));
      }
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Future<void> tapStudent(Profile profile) async {
    setState(() => selectedStudentId = profile.studentId);
    await Navigator.pushNamed(context, '/student-details', arguments: profile);
    if (mounted) {
      setState(() {});
      await _saveStudents();
    }
  }

  void favoriteStudent(Profile profile) {
    setState(() {
      profile.isFavorite = !profile.isFavorite;
    });
    _saveStudents();
    showMessage(
      profile.isFavorite
          ? '${profile.name} added to favorites'
          : '${profile.name} removed from favorites',
    );
  }

  Future<void> editStudent(Profile profile) async {
    final nameController = TextEditingController(text: profile.name);
    final courseController = TextEditingController(text: profile.courseSection);
    final emailController = TextEditingController(text: profile.email);
    final ageController = TextEditingController(text: profile.age.toString());
    final hobbyController = TextEditingController(text: profile.hobby);
    final subjectController = TextEditingController(
      text: profile.favoriteSubject,
    );

    bool isActive = profile.isActive;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Student'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Student ID: ${profile.studentId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: courseController,
                      decoration: const InputDecoration(
                        labelText: 'Course & Section',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: hobbyController,
                      decoration: const InputDecoration(
                        labelText: 'Hobby',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Favorite Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final course = courseController.text.trim();
                    final email = emailController.text.trim();
                    final age = int.tryParse(ageController.text.trim());

                    if (name.isEmpty ||
                        course.isEmpty ||
                        email.isEmpty ||
                        age == null ||
                        age < 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter valid student information.',
                          ),
                        ),
                      );
                      return;
                    }

                    profile.name = name;
                    profile.courseSection = course;
                    profile.email = email;
                    profile.age = age;
                    profile.hobby = hobbyController.text.trim();
                    profile.favoriteSubject = subjectController.text.trim();
                    profile.isActive = isActive;

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    courseController.dispose();
    emailController.dispose();
    ageController.dispose();
    hobbyController.dispose();
    subjectController.dispose();

    if (!mounted) return;

    if (saved == true) {
      setState(() {});

      await _saveStudents();

      if (!mounted) return;

      showMessage('${profile.name} updated successfully');
    }
  }

  void toggleActive(Profile profile) {
    setState(() {
      profile.isActive = !profile.isActive;
    });
    _saveStudents();
    showMessage(
      '${profile.name} is now ${profile.isActive ? 'Active' : 'Inactive'}',
    );
  }

  void deleteStudent(Profile profile) {
    setState(() {
      profiles.remove(profile);
      if (selectedStudentId == profile.studentId) {
        selectedStudentId = null;
      }
    });
    _saveStudents();
    showMessage('${profile.name} removed');
  }

  Future<void> reloadStudents() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    final saved = await StudentLocalStorage.load();
    if (!mounted) return;
    setState(() {
      profiles = saved ?? createInitialProfiles();
      selectedStudentId = null;
      sortedAlphabetically = false;
      isLoading = false;
    });
    showMessage('Student directory loaded');
  }

  void restoreStudents() {
    setState(() {
      profiles = createInitialProfiles();
      selectedStudentId = null;
      sortedAlphabetically = false;
    });
    _saveStudents();
    showMessage('Student directory restored');
  }

  Widget infoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _openAddStudent,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reload students',
            onPressed: isLoading ? null : reloadStudents,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: sortedAlphabetically ? 'Original order' : 'Sort A to Z',
            icon: Icon(
              sortedAlphabetically
                  ? Icons.sort_by_alpha
                  : Icons.sort_by_alpha_outlined,
            ),
            onPressed: toggleSort,
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4527A0), Color(0xFFD84315)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFEDE7F6)],
          ),
        ),
        child: ListView(
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4527A0), Color(0xFFE64A19)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
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
                          'assets/image/DBTC-_School_Logo.png',
                          width: 160,
                          height: 160,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don Bosco Technical College - Cebu',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 12),
                        Divider(color: Colors.deepPurple, thickness: 1),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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
                  const SizedBox(width: 10),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${profiles.length} students',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (directoryView == DirectoryView.students)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Text(
                  'Active: ${profiles.where((p) => p.isActive).length}   '
                  'Inactive: ${profiles.where((p) => !p.isActive).length}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (directoryView == DirectoryView.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 65),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading student directory...'),
                  ],
                ),
              )
            else if (directoryView == DirectoryView.empty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.deepPurple.shade200,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No students found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Student list is empty.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple.shade300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: restoreStudents,
                      icon: const Icon(Icons.restore),
                      label: const Text('Restore students'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final accent = accents[index % accents.length];
                  final isSelected = selectedStudentId == profile.studentId;

                  return Container(
                    key: ValueKey(profile.studentId),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.shade100,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: isSelected
                            ? const Color(0xFFFFF8E1)
                            : Colors.white,
                        child: InkWell(
                          onTap: () => tapStudent(profile),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(width: 7, color: accent),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                accent.shade300,
                                                accent.shade700,
                                              ],
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: accent.shade50,
                                            backgroundImage: AssetImage(
                                              profile.image,
                                            ),
                                            onBackgroundImageError: (_, _) {},
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                profile.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: accent.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: profile.isActive
                                                      ? Colors.green.shade100
                                                      : Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  profile.isActive
                                                      ? 'Active'
                                                      : 'Inactive',
                                                  style: TextStyle(
                                                    color: profile.isActive
                                                        ? Colors.green.shade800
                                                        : Colors.grey.shade800,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Text(
                                                  'Selected student',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (profile.isFavorite)
                                                const Text(
                                                  '♥ Favorite',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              if (!profile.isActive)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 4,
                                                  ),
                                                  child: Text(
                                                    '⚠ This student is inactive',
                                                    style: TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: accent.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '${profile.courseSection} • Age ${profile.age}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: accent.shade800,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text('Hobby: ${profile.hobby}'),
                                              Text(
                                                'Height: ${profile.height} cm',
                                              ),
                                              Divider(
                                                height: 14,
                                                color: accent.shade100,
                                              ),
                                              infoRow(
                                                Icons.badge_outlined,
                                                'ID: ${profile.studentId}',
                                                accent,
                                              ),
                                              infoRow(
                                                Icons.email_outlined,
                                                'Email: ${profile.email}',
                                                accent,
                                              ),
                                              infoRow(
                                                Icons.menu_book_outlined,
                                                'Favorite subject: ${profile.favoriteSubject}',
                                                accent,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip: 'Change Active Status',
                                              icon: Icon(
                                                profile.isActive
                                                    ? Icons.toggle_on
                                                    : Icons.toggle_off,
                                                color: profile.isActive
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              onPressed: () =>
                                                  toggleActive(profile),
                                            ),
                                            IconButton(
                                              tooltip: 'Favorite',
                                              icon: Icon(
                                                profile.isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  favoriteStudent(profile),
                                            ),
                                            IconButton(
                                              tooltip: 'Edit',
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () =>
                                                  editStudent(profile),
                                            ),
                                            IconButton(
                                              tooltip: 'Delete',
                                              icon: Icon(
                                                Icons.delete_outline,
                                                color: accent.shade700,
                                              ),
                                              onPressed: () =>
                                                  deleteStudent(profile),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class StudentDetailsScreen extends StatefulWidget {
  const StudentDetailsScreen({super.key, required this.profile});
  final Profile profile;

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  Future<void> editStudent() async {
    final name = TextEditingController(text: widget.profile.name);
    final course = TextEditingController(text: widget.profile.courseSection);
    bool active = widget.profile.isActive;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: const Text('Edit Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Student ID: ${widget.profile.studentId}'),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: course,
                  decoration: const InputDecoration(
                    labelText: 'Course & Section',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (value) => updateDialog(() => active = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty || course.text.trim().isEmpty) {
                  return;
                }


                widget.profile.name = name.text.trim();
                widget.profile.courseSection = course.text.trim();
                widget.profile.isActive = active;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    course.dispose();
    if (!mounted) return;
    if (saved == true) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Student updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Student Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.deepPurple.shade50,
              backgroundImage: AssetImage(profile.image),
              onBackgroundImageError: (_, _) {},
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student ID: ${profile.studentId}'),
                    const SizedBox(height: 8),
                    Text('Course: ${profile.courseSection}'),
                    const SizedBox(height: 8),
                    Text('Status: ${profile.isActive ? 'Active' : 'Inactive'}'),
                    const SizedBox(height: 8),
                    Text('Age: ${profile.age}'),
                    const SizedBox(height: 8),
                    Text('Hobby: ${profile.hobby}'),
                    const SizedBox(height: 8),
                    Text('Height: ${profile.height} cm'),
                    const SizedBox(height: 8),
                    Text('Email: ${profile.email}'),
                    const SizedBox(height: 8),
                    Text('Favorite subject: ${profile.favoriteSubject}'),
                    const SizedBox(height: 8),
                    Text('Favorite: ${profile.isFavorite ? 'Yes' : 'No'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: editStudent,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Student'),
            ),
          ],
        ),
      ),
    );
  }
}

// CTF 8: New enrollment form, added without changing the original directory UI.
class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _courseController = TextEditingController();
  final _yearLevelController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    _fullNameController.dispose();
    _courseController.dispose();
    _yearLevelController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final existingIds =
        ModalRoute.of(context)?.settings.arguments as List<String>? ?? [];
    if (existingIds.contains(value!.trim())) {
      return 'Student ID already exists';
    }
    return null;
  }

  String? _validateYearLevel(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final year = int.tryParse(value!.trim());
    if (year == null || year < 1 || year > 5) {
      return 'Enter a valid year level (1–5)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final newStudent = Profile(
      image: 'assets/image/DBTC-_School_Logo.png',
      name: _fullNameController.text.trim(),
      courseSection:
          '${_courseController.text.trim()} ${_yearLevelController.text.trim()}',
      age: 0, // Enrollment form does not request age.
      hobby: 'Not specified',
      height: 0,
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim(),
      favoriteSubject: 'Not specified',
    );

    _studentIdController.clear();
    _fullNameController.clear();
    _courseController.clear();
    _yearLevelController.clear();
    _emailController.clear();
    Navigator.pop(context, newStudent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.person_add_alt_1,
                size: 76,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 18),
              const Text(
                'Add Student',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fill in the details to add a new student.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
                validator: _validateStudentId,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearLevelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year Level',
                  border: OutlineInputBorder(),
                ),
                validator: _validateYearLevel,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Enroll Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
