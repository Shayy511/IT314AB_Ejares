import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 222, 66, 14)),
        fontFamily: 'Georgia' //Custom font family
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
  

  void _incrementCounter() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.deepPurple, //Custom app bar color
        
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      ),
      backgroundColor: const Color(0xFFFFF3E0), //Background color of the whole screen
      body: Center(
        
      
        child: Column(
         
          mainAxisAlignment: .center,
          children: [
            

            Image.asset('assets/image/DBTC-_School_Logo.png', width: 200, height: 200),

            const Icon(
                Icons.person_pin_circle,
                size: 48,
                color: Colors.deepPurple,
              ),
            const SizedBox(height: 12),

            const Text(
                'Shairha May Ejares',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            const Text(
              'BSIT-3',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'My First Flutter Application',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            const Text(
              '08/11/26',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
