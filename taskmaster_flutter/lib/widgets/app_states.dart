// lib/widgets/app_states.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ── SHIMMER LOADING ──────────────────────────────────────────────────────────
class TaskShimmerList extends StatelessWidget {
  const TaskShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Container(
                height: 16,
                width: 200,
                color: Colors.white,
                borderRadius: BorderRadius.circular(4)),
          ]),
          const SizedBox(height: 8),
          Container(
              height: 12,
              width: double.infinity,
              color: Colors.white,
              borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 4),
          Container(
              height: 12,
              width: 150,
              color: Colors.white,
              borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 12),
          Row(children: [
            Container(
                height: 12,
                width: 80,
                color: Colors.white,
                borderRadius: BorderRadius.circular(4)),
            const Spacer(),
            Container(
                height: 22,
                width: 70,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)),
          ]),
        ],
      ),
    );
  }
}

// ── EMPTY STATE ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.task_alt, size: 40, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ERROR STATE ──────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_outlined,
                  size: 40, color: cs.onErrorContainer),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── LOADING BUTTON ───────────────────────────────────────────────────────────
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8)
                ],
                Text(label),
              ],
            ),
    );
  }
}
