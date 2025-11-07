import 'package:flutter/material.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final String maintenanceId;

  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Details'),
      ),
      body: Center(
        child: Text('Maintenance Detail Screen - ID: $maintenanceId'),
      ),
    );
  }
}




