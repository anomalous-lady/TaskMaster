// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/routes.dart';
import '../../widgets/app_states.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'emilys'); // dummyjson default
  final _passwordController =
      TextEditingController(text: 'emilyspass'); // dummyjson default
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    ref.listen(authProvider, (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: cs.error),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.task_alt,
                      color: cs.onPrimaryContainer, size: 28),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 24),
                Text(
                  'Welcome back',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your tasks',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: cs.onSurfaceVariant),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                const SizedBox(height: 40),

                // Fields
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Username / Email',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Username is required' : null,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  onFieldSubmitted: (_) => _login(),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 8),
                // Hint for demo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: cs.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo: username=emilys  password=emilyspass',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 280.ms),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    isLoading: auth.isLoading,
                    onPressed: _login,
                    label: 'Sign In',
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.register),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
