import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final requests = [
      {
        'title': 'Leaking Kitchen Tap',
        'status': 'In Progress',
        'statusColor': const Color(0xFFF59E0B),
        'date': 'Reported 2 days ago',
      },
      {
        'title': 'Broken Window Latch',
        'status': 'Pending',
        'statusColor': const Color(0xFFF87171),
        'date': 'Reported 1 week ago',
      },
      {
        'title': 'AC Filter Replacement',
        'status': 'Completed',
        'statusColor': const Color(0xFF10B981),
        'date': 'Completed last month',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0B2B40)),
          onPressed: () => context.go('/dashboard?bypass=1'),
        ),
        centerTitle: true,
        title: Text(
          'Maintenance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/maintenance/create?bypass=1'),
            icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF008F85)),
            label: const Text(
              'New Request',
              style: TextStyle(
                color: Color(0xFF008F85),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 20),
            Text(
              'Active Requests',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B2B40),
              ),
            ),
            const SizedBox(height: 12),
            ...requests
                .map((request) => _MaintenanceCard(data: request))
                .toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.build_circle_rounded, color: Color(0xFF008F85), size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 open maintenance requests',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B2B40),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Average response time: 4 hours. Keep an eye on your request updates!',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final Map<String, Object> data;

  const _MaintenanceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = data['statusColor'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.build_outlined, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B2B40),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['date'] as String,
                  style: const TextStyle(color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              data['status'] as String,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




