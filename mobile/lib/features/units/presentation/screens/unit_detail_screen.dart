import 'package:flutter/material.dart';

class UnitDetailScreen extends StatelessWidget {
  final String unitId;

  const UnitDetailScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Details'),
      ),
      body: Center(
        child: Text('Unit Detail Screen - ID: $unitId'),
      ),
    );
  }
}




