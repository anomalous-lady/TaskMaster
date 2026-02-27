// lib/providers/tasks_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import 'auth_provider.dart';

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

// Task filter state
enum TaskFilter { all, pending, inProgress, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Tasks state
class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    bool clearError = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final ApiService _api;
  final CacheService _cache;
  static const int _pageSize = 10;

  TasksNotifier(this._api, this._cache) : super(const TasksState());

  Future<void> loadTasks({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      state = const TasksState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final skip = refresh ? 0 : state.currentPage * _pageSize;
      final tasks = await _api.fetchTasks(skip: skip, limit: _pageSize);

      // Cache first page
      if (refresh || state.currentPage == 0) {
        await _cache.cacheTasks(tasks);
      }

      final allTasks = refresh ? tasks : [...state.tasks, ...tasks];
      state = state.copyWith(
        tasks: allTasks,
        isLoading: false,
        hasMore: tasks.length == _pageSize,
        currentPage: refresh ? 1 : state.currentPage + 1,
      );
    } catch (e) {
      // Fall back to cache on error
      if (refresh) {
        final cached = _cache.getCachedTasks();
        if (cached.isNotEmpty) {
          state = state.copyWith(
            tasks: cached,
            isLoading: false,
            error: 'Showing cached data. ${e.toString()}',
            hasMore: false,
          );
          return;
        }
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createTask(Map<String, dynamic> data) async {
    try {
      final task = await _api.createTask(data);
      await _cache.cacheTask(task);
      state = state.copyWith(tasks: [task, ...state.tasks]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _api.updateTask(id, data);
      await _cache.cacheTask(updated);
      final tasks = state.tasks.map((t) => t.id == id ? updated : t).toList();
      state = state.copyWith(tasks: tasks);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _api.deleteTask(id);
      await _cache.removeTask(id);
      final tasks = state.tasks.where((t) => t.id != id).toList();
      state = state.copyWith(tasks: tasks);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(
    ref.read(apiServiceProvider),
    ref.read(cacheServiceProvider),
  );
});

// Filtered tasks derived provider
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider).tasks;
  final filter = ref.watch(taskFilterProvider);

  switch (filter) {
    case TaskFilter.pending:
      return tasks.where((t) => t.status == 'pending').toList();
    case TaskFilter.inProgress:
      return tasks.where((t) => t.status == 'in_progress').toList();
    case TaskFilter.completed:
      return tasks.where((t) => t.status == 'completed').toList();
    case TaskFilter.all:
      return tasks;
  }
});
