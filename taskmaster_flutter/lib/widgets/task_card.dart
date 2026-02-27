// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChange;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onStatusChange,
    required this.index,
  });

  Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return cs.primary;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColor = _statusColor(context, task.status);

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 60).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          delay: (index * 60).ms,
        ),
      ],
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status indicator
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.status == 'completed'
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == 'completed'
                              ? theme.disabledColor
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Quick complete checkbox
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onStatusChange(
                        task.status == 'completed' ? 'pending' : 'completed',
                      ),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: task.status == 'completed'
                              ? Colors.green.withOpacity(0.1)
                              : cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.status == 'completed'
                                ? Colors.green
                                : cs.outline,
                          ),
                        ),
                        child: task.status == 'completed'
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.green)
                            : null,
                      ),
                    ),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Due date
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: task.isOverdue ? Colors.red : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(task.dueDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            task.isOverdue ? Colors.red : cs.onSurfaceVariant,
                        fontWeight: task.isOverdue
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (task.isOverdue) ...[
                      const SizedBox(width: 4),
                      const Text(
                        'Overdue',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                    const Spacer(),
                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(task.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: cs.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
