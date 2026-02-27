// lib/models/task_model.dart
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String status; // 'pending', 'in_progress', 'completed'

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: DateTime.parse(json['due_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != 'completed';
}
