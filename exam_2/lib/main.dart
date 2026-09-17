import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SocialScreen(),
    );
  }
}

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  final String appTitle = 'Social';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121115),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              appTitle.isNotEmpty ? appTitle : 'Social',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
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
                Text(
                  'Messages',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 20),
                Text(
                  'Requests',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Card(
              color: const Color(0xFF1B1A1F),
              child: const Padding(
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
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.play_circle, color: Colors.redAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  'VALORANT  3',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            friendCard(name: friend1Name, status: friend1Status, activity: friend1Game),
            friendCard(name: friend2Name, status: friend2Status, activity: friend2Game),
            friendCard(name: friend3Name, status: friend3Status, activity: friend3Game),
            const SizedBox(height: 16),
            const Text(
              'Online  4',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            friendCard(name: friend4Name, status: friend4Status, activity: friend4Game),
            friendCard(name: friend5Name, status: friend5Status, activity: friend5Game),
          ],
        ),
      ),
    );
  }

  Widget friendCard({
    required String name,
    required String status,
    required String activity,
  }) {
    final String displayName = name.isNotEmpty ? name : 'Unknown Friend';
    final String displayStatus = status.isNotEmpty ? status : 'Offline';
    final String displayActivity = activity.isNotEmpty ? activity : '';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle;

    return Card(
      color: const Color.fromARGB(0, 61, 59, 59),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 21,
                backgroundColor: Color(0xFF2A2930),
                child: Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(statusIcon, size: 16, color: statusColor),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.monitor, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      displayActivity.isEmpty
                          ? displayStatus
                          : '$displayStatus - $displayActivity',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ); 
  }
}
