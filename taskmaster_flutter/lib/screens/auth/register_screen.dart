// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/routes.dart';
import '../../widgets/app_states.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
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
                const SizedBox(height: 32),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create account',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Start organizing your tasks today',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: cs.onSurfaceVariant),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, 'Name'),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
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
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  obscureText: _obscureConfirm,
                  validator: (v) {
                    if (v != _passwordController.text)
                      return 'Passwords do not match';
                    return Validators.password(v);
                  },
                  onFieldSubmitted: (_) => _register(),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    isLoading: auth.isLoading,
                    onPressed: _register,
                    label: 'Create Account',
                  ),
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: cs.onSurfaceVariant)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.login),
                      child: const Text('Sign In'),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
