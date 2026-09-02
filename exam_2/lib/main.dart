import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant',
      theme: ThemeData.dark(),
      home: SocialScreen(),
    );
  }
}

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  final String apptitle = 'Social';

  final String friend1Name = 'MissYouLikeKrazy';
  final String friend1Status = 'Online';
  final String friend1Game = 'VALORANT';

  final String friend2Name = 'bread';
  final String friend2Status = 'Playing';
  final String friend2Game = 'VALORANT';

  final String friend3Name = 'The14th';
  final String friend3Status = 'Playing';
  final String friend3Game = 'VALORANT';

  final String friend4Name = 'Carlvendish';
  final String friend4Status = 'Away';
  final String friend4Game = 'Riot Mobile';

  final String friend5Name = 'D1yah';
  final String friend5Status = 'Away';
  final String friend5Game = 'Riot Mobile';

  @override
  State<SocialScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SocialScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121115),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Social',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: const [
                Text(
                  'Friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20),
                Text('Messages', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 20),
                Text('Requests', style: TextStyle(color: Colors.grey)),
                Divider(color: Colors.grey),
                SizedBox(height: 8),

                Divider(color: Colors.grey),
                SizedBox(height: 8),

                Card(
                  color: Color(0xFF1B1A1F),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Search', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
