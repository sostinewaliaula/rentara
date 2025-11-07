import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool showNotificationsDot;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    this.showNotificationsDot = true,
  });

  static const _routes = [
    '/dashboard',
    '/payments',
    '/maintenance',
    '/settings',
  ];

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;
    final route = _routes[index];
    context.go('$route?bypass=1');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) => _navigate(context, index),
      selectedItemColor: const Color(0xFF008F85),
      unselectedItemColor: const Color(0xFF94A3B8),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments_rounded),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle_rounded),
          label: 'Maintenance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
