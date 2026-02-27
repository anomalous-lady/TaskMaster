// lib/services/cache_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class CacheService {
  static const String _tasksBox = 'tasks_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    await Hive.openBox<Task>(_tasksBox);
  }

  Box<Task> get _box => Hive.box<Task>(_tasksBox);

  Future<void> cacheTasks(List<Task> tasks) async {
    final map = {for (var t in tasks) t.id: t};
    await _box.putAll(map);
  }

  List<Task> getCachedTasks() {
    return _box.values.toList();
  }

  Future<void> cacheTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> removeTask(String id) async {
    await _box.delete(id);
  }

  Future<void> clearCache() async {
    await _box.clear();
  }
}
