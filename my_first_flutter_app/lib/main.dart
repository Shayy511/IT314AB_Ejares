import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 222, 66, 14),
        ),
        fontFamily: 'Georgia',
      ),
      home: const MyHomePage(title: 'My First Flutter Application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFFFFF3E0),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/DBTC-_School_Logo.png',
                        width: 200,
                        height: 200,
                      ),

                      const Icon(
                        Icons.person_pin_circle,
                        size: 48,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Shairha May B. Ejares',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      const Text('BSIT-3', style: TextStyle(fontSize: 18)),

                      const SizedBox(height: 8),

                      const Text(
                        'My First Flutter Application',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'August 11, 2026',
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 8),
                      const Divider(color: Colors.deepPurple, thickness: 1),
                      const SizedBox(height: 12),

                      const Text(
                        'I am excited to learn more about Flutter and build amazing apps!',
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.deepPurple, thickness: 1),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Age: 20'),
                          SizedBox(width: 20),
                          Text('Birthdate: May 11, 2006'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Code for the Second Card
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Favorites',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Favorite Sports',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const Text('Volleyball and Swimming'),

                      const SizedBox(height: 12),

                      const Text(
                        'Favorite Colors',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const Text('Red and Black'),

                      const SizedBox(height: 12),

                      const Text(
                        'Favorite Movie',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const Text('The Chronicles of Narnia'),

                      const SizedBox(height: 12),
                      const Divider(color: Colors.deepPurple, thickness: 2),
                      const SizedBox(height: 12),

                      Row(
                        children: const [
                          Text(
                            'Favorite Food:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Text('Chicken Adobo'),
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
    );
  }
}
