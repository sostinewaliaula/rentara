import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentara/core/providers/auth_provider.dart';
import 'package:rentara/features/auth/presentation/screens/login_screen.dart';
import 'package:rentara/features/auth/presentation/screens/register_screen.dart';
import 'package:rentara/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rentara/features/payments/presentation/screens/payments_screen.dart';
import 'package:rentara/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:rentara/features/maintenance/presentation/screens/maintenance_detail_screen.dart';
import 'package:rentara/features/maintenance/presentation/screens/create_maintenance_screen.dart';
import 'package:rentara/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:rentara/features/profile/presentation/screens/profile_screen.dart';
import 'package:rentara/features/units/presentation/screens/units_screen.dart';
import 'package:rentara/features/units/presentation/screens/unit_detail_screen.dart';
import 'package:rentara/features/splash/presentation/screens/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';

      if (!isAuthenticated && !isLoggingIn && state.matchedLocation != '/splash') {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/units',
        builder: (context, state) => const UnitsScreen(),
      ),
      GoRoute(
        path: '/units/:id',
        builder: (context, state) {
          final unitId = state.pathParameters['id']!;
          return UnitDetailScreen(unitId: unitId);
        },
      ),
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/maintenance/create',
        builder: (context, state) => const CreateMaintenanceScreen(),
      ),
      GoRoute(
        path: '/maintenance/:id',
        builder: (context, state) {
          final maintenanceId = state.pathParameters['id']!;
          return MaintenanceDetailScreen(maintenanceId: maintenanceId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}




