import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/connection_viewmodel.dart';

class ConnectionTestScreen extends StatelessWidget {
  const ConnectionTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConnectionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Connection Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
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
        child: Center(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    vm.isConnected ? Icons.check_circle : Icons.storage,
                    size: 90,
                    color: vm.isConnected ? Colors.green : Colors.deepPurple,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Neon PostgreSQL',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vm.status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: vm.isConnected ? Colors.green : Colors.black87,
                    ),
                  ),
                  if (vm.isConnected) ...[
                    const SizedBox(height: 16),
                    Text('Database: ${vm.databaseName}'),
                    const SizedBox(height: 8),
                    Text('Total Students: ${vm.studentCount}'),
                  ],
                  const SizedBox(height: 24),
                  if (vm.isLoading)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: vm.testConnection,
                      icon: const Icon(Icons.link),
                      label: const Text('Test Connection'),
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
