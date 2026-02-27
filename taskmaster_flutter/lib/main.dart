// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/cache_service.dart';
import 'theme/app_theme.dart';
import 'utils/routes.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tasks/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive cache
  final cache = CacheService();
  await cache.init();
  runApp(
    ProviderScope(
      overrides: [
        // Provide the initialized cache service
        cacheServiceProviderOverride(cache),
      ],
      child: const TaskMasterApp(),
    ),
  );
}

// Override to pass initialized CacheService into providers
final cacheServiceProviderOverride = (CacheService cache) =>
    cacheServiceProvider.overrideWithValue(cache);

class TaskMasterApp extends ConsumerWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TaskMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
      },
    );
  }
}
