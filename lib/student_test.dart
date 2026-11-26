import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/student_viewmodel.dart';
import 'views/student_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StudentViewModel()..loadStudents(),
      child: const StudentApp(),
    ),
  );
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enrollment Management System',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 222, 66, 14),
        ),
        fontFamily: 'Georgia',
      ),

      home: const StudentListScreen(),

      routes: {
        '/student-list': (_) => const StudentListScreen(),

        '/add-student': (_) => const AddStudentScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/student-details' && settings.arguments is int) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) =>
                StudentDetailsScreen(studentId: settings.arguments as int),
          );
        }

        return null;
      },
    );
  }
}
