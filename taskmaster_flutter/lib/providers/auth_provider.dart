// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Auth state
class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? isLoading, String? error, bool clearUser = false}) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await _api.getToken();
    if (token != null) {
      // Restore session with a minimal user object
      state = state.copyWith(
        user: AuthUser(id: '', email: '', name: '', token: token),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _api.register(name, email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(apiServiceProvider)),
);
