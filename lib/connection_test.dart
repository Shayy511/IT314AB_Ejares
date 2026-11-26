import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/connection_viewmodel.dart';
import 'views/connection_test_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConnectionViewModel(),
      child: const ConnectionTestApp(),
    ),
  );
}

class ConnectionTestApp extends StatelessWidget {
  const ConnectionTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        fontFamily: 'Georgia',
      ),
      home: const ConnectionTestScreen(),
    );
  }
}
