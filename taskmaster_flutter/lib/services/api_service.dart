// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/task_model.dart';
import '../models/auth_model.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  // Replace with your real API. We use dummyjson.com as a free mock backend.

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) {
        handler.next(e);
      },
    ));
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  Future<AuthUser> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': email,
        'password': password,
        'expiresInMins': 60,
      });
      final user = AuthUser.fromJson({
        ...response.data,
        'token': response.data['token'] ?? response.data['accessToken'] ?? '',
        'name': response.data['firstName'] ?? email,
        'email': email,
      });
      await _storage.write(key: 'auth_token', value: user.token);
      await _storage.write(key: 'user_id', value: user.id);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthUser> register(String name, String email, String password) async {
    try {
      // dummyjson doesn't support real registration; we mock it here.
      // Replace with your real endpoint.
      final response = await _dio.post('/users/add', data: {
        'firstName': name,
        'email': email,
        'password': password,
      });
      // Simulate a token for mock registration
      final user = AuthUser(
        id: response.data['id'].toString(),
        email: email,
        name: name,
        token: 'mock_token_${response.data['id']}',
      );
      await _storage.write(key: 'auth_token', value: user.token);
      await _storage.write(key: 'user_id', value: user.id);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  // ── TASKS ─────────────────────────────────────────────────────────────────

  Future<List<Task>> fetchTasks({int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/todos', queryParameters: {
        'limit': limit,
        'skip': skip,
      });
      final todos = response.data['todos'] as List;
      return todos.map((t) => Task(
        id: t['id'].toString(),
        title: t['todo'] ?? '',
        description: 'Task #${t['id']}',
        status: (t['completed'] == true) ? 'completed' : 'pending',
        dueDate: DateTime.now().add(Duration(days: t['id'] % 10)),
        createdAt: DateTime.now(),
      )).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> createTask(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/todos/add', data: {
        'todo': data['title'],
        'completed': data['status'] == 'completed',
        'userId': 1,
      });
      return Task(
        id: response.data['id'].toString(),
        title: data['title'],
        description: data['description'] ?? '',
        status: data['status'] ?? 'pending',
        dueDate: data['due_date'] != null
            ? DateTime.parse(data['due_date'])
            : DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/todos/$id', data: {
        'todo': data['title'],
        'completed': data['status'] == 'completed',
      });
      return Task(
        id: response.data['id'].toString(),
        title: data['title'] ?? response.data['todo'],
        description: data['description'] ?? '',
        status: data['status'] ?? (response.data['completed'] ? 'completed' : 'pending'),
        dueDate: data['due_date'] != null
            ? DateTime.parse(data['due_date'])
            : DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('/todos/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── ERROR HANDLING ────────────────────────────────────────────────────────

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'Invalid credentials.';
        if (statusCode == 404) return 'Resource not found.';
        if (statusCode == 500) return 'Server error. Please try again later.';
        return 'Error: ${e.response?.statusMessage}';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
