import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/core/utils.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

class TodoListView extends StatelessWidget {
  final List<TodoModel> todos;
  final ValueChanged<String> onToggleComplete;
  final ValueChanged<TodoModel> onOpen;

  const TodoListView({
    super.key,
    required this.todos,
    required this.onToggleComplete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final todo = todos[i];
        return _TodoListItem(
          todo: todo,
          onTap: () => onOpen(todo),
          onToggleComplete: () => onToggleComplete(todo.id),
        );
      },
    );
  }
}

class _TodoListItem extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onToggleComplete;
  final Function()? onTap;

  const _TodoListItem({
    required this.todo,
    required this.onToggleComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'Assigned: ${Utils.formatTodoDate(todo.assignedDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
