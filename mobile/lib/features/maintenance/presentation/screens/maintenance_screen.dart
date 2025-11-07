import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/maintenance/create'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Maintenance Screen - To be implemented'),
      ),
    );
  }
}




