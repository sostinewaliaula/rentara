import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentara/core/router/app_router.dart';
import 'package:rentara/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RentaraApp(),
    ),
  );
}

class RentaraApp extends ConsumerWidget {
  const RentaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Rentara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}




