// lib/screens/tasks/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/app_states.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _status;
  late DateTime _dueDate;
  bool _isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? 'pending';
    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': _status,
      'due_date': _dueDate.toIso8601String(),
    };

    bool success;
    if (isEditing) {
      success = await ref
          .read(tasksProvider.notifier)
          .updateTask(widget.task!.id, data);
    } else {
      success = await ref.read(tasksProvider.notifier).createTask(data);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEditing ? 'Task updated!' : 'Task created!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(tasksProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error ?? 'Failed to save task'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Task Title', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Design the landing page',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: Validators.taskTitle,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Description
              Text('Description', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Add more details (optional)',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 20),

              // Status
              Text('Status', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              _StatusSelector(
                selected: _status,
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 20),

              // Due date
              Text('Due Date', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: cs.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_dueDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  isLoading: _isSaving,
                  onPressed: _save,
                  label: isEditing ? 'Save Changes' : 'Create Task',
                  icon: isEditing ? Icons.save : Icons.add_task,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text('This cannot be undone.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await ref
                            .read(tasksProvider.notifier)
                            .deleteTask(widget.task!.id);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Task'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _StatusSelector({required this.selected, required this.onChanged});

  static const _statuses = [
    {
      'value': 'pending',
      'label': 'Pending',
      'icon': Icons.radio_button_unchecked,
      'color': Colors.orange
    },
    {
      'value': 'in_progress',
      'label': 'In Progress',
      'icon': Icons.timelapse,
      'color': Color(0xFF6C63FF)
    },
    {
      'value': 'completed',
      'label': 'Completed',
      'icon': Icons.check_circle,
      'color': Colors.green
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _statuses.map((s) {
        final isSelected = selected == s['value'];
        final color = s['color'] as Color;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChanged(s['value'] as String),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(s['icon'] as IconData,
                        color: isSelected
                            ? color
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected
                            ? color
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
