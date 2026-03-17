import 'package:flutter/material.dart';

class TodoLoadingView extends StatelessWidget {
  const TodoLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class TodoErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TodoErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class TodoEmptyView extends StatelessWidget {
  const TodoEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No todos yet. Tap + to add one!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
