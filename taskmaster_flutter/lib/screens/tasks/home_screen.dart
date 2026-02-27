// lib/screens/tasks/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../utils/routes.dart';
import '../../widgets/task_card.dart';
import '../../widgets/app_states.dart';
import 'task_form_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider.notifier).loadTasks(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(tasksProvider.notifier).loadTasks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tasksProvider.notifier).deleteTask(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tasksState = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final auth = ref.watch(authProvider);

    ref.listen(tasksProvider, (_, next) {
      if (next.error != null && !next.error!.contains('cached')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: cs.error,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () =>
                  ref.read(tasksProvider.notifier).loadTasks(refresh: true),
            ),
          ),
        );
        ref.read(tasksProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TaskMaster',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (auth.user?.name.isNotEmpty == true)
              Text(
                'Hello, ${auth.user!.name}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted)
                Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          _StatsBar(tasks: tasksState.tasks),
          // Filter chips
          _FilterBar(selectedFilter: filter),
          // Task list
          Expanded(
            child: _buildBody(tasksState, filteredTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ).animate().scale(delay: 600.ms),
    );
  }

  Widget _buildBody(TasksState state, List filteredTasks) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const TaskShimmerList();
    }
    if (state.error != null && state.tasks.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: () =>
            ref.read(tasksProvider.notifier).loadTasks(refresh: true),
      );
    }
    if (filteredTasks.isEmpty) {
      return EmptyState(
        title: 'No tasks yet',
        subtitle: 'Tap the button below to create your first task',
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        actionLabel: 'Create Task',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(tasksProvider.notifier).loadTasks(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: filteredTasks.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredTasks.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            index: index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
            ),
            onDelete: () => _showDeleteDialog(task.id),
            onStatusChange: (newStatus) => ref
                .read(tasksProvider.notifier)
                .updateTask(task.id, {...task.toJson(), 'status': newStatus}),
          );
        },
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final List tasks;
  const _StatsBar({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'completed').length;
    final pending = tasks.where((t) => t.status == 'pending').length;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: total, color: Colors.white),
          _Divider(),
          _StatItem(
              label: 'Pending', value: pending, color: Colors.orange.shade200),
          _Divider(),
          _StatItem(
              label: 'Done',
              value: completed,
              color: Colors.greenAccent.shade200),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 30, width: 1, color: Colors.white30);
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800, color: color),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final TaskFilter selectedFilter;
  const _FilterBar({required this.selectedFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TaskFilter.values.map((f) {
          final label = f.name[0].toUpperCase() + f.name.substring(1);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f == TaskFilter.inProgress ? 'In Progress' : label),
              selected: selectedFilter == f,
              onSelected: (_) =>
                  ref.read(taskFilterProvider.notifier).state = f,
            ),
          );
        }).toList(),
      ),
    );
  }
}
