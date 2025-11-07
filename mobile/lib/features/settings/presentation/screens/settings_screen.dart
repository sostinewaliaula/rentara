import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/widgets/main_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final settingsOptions = [
      {'title': 'Profile', 'icon': Icons.person_outline_rounded},
      {'title': 'Notifications', 'icon': Icons.notifications_outlined},
      {'title': 'Security', 'icon': Icons.lock_outline_rounded},
      {'title': 'About Rentara', 'icon': Icons.info_outline_rounded},
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
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0B2B40),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemBuilder: (context, index) {
          final option = settingsOptions[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListTile(
              onTap: () {},
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FBF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option['icon'] as IconData, color: const Color(0xFF008F85)),
              ),
              title: Text(
                option['title'] as String,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B2B40),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemCount: settingsOptions.length,
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
    );
  }
}
