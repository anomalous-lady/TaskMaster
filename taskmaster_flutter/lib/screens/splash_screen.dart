// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../utils/routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final isAuth = ref.read(authProvider).isAuthenticated;
    Navigator.pushReplacementNamed(context, isAuth ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.task_alt, color: cs.primary, size: 40),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'TaskMaster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Stay organized. Get things done.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
