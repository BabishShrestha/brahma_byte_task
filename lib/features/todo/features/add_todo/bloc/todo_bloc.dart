import 'dart:async';
import 'package:todo_app/features/todo/core/db_helper.dart';
import 'package:todo_app/features/todo/core/notification_service.dart';
import 'package:todo_app/features/todo/features/add_todo/bloc/todo_event.dart';
import 'package:todo_app/features/todo/features/add_todo/bloc/todo_state.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────
// BLoC with SQLite Integration
// ─────────────────────────────────────────────

class TodoBloc {
  final _stateController = StreamController<TodoBlocState>.broadcast();
  Stream<TodoBlocState> get stream => _stateController.stream;

  final _uuid = const Uuid();
  final _dbHelper = DatabaseHelper.instance;
  final _notificationService = NotificationService.instance;

  /// In-memory cache for faster access
  final List<TodoModel> _todos = [];

  TodoBloc() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      print('Notification init failed: $e');
    }
  }

  Future<void> _scheduleNotificationIfNeeded(TodoModel todo) async {
    try {
      await _notificationService.scheduleTodoNotification(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        scheduledDate: todo.assignedDate,
      );
    } catch (e) {
      print('Failed to schedule notification for todo ${todo.id}: $e');
    }
  }

  Future<void> _cancelNotification(String todoId) async {
    try {
      await _notificationService.cancelNotification(todoId);
    } catch (e) {
      print('Failed to cancel notification for todo $todoId: $e');
    }
  }

  void dispatch(TodoEvent event) {
    try {
      if (event is LoadTodos) {
        _onLoadTodos();
      } else if (event is AddTodo) {
        _onAddTodo(event);
      } else if (event is UpdateTodo) {
        _onUpdateTodo(event);
      } else if (event is DeleteTodo) {
        _onDeleteTodo(event);
      } else if (event is ToggleTodoComplete) {
        _onToggleComplete(event);
      }
    } catch (e) {
      _stateController.add(TodoError('Unexpected error: $e'));
    }
  }

  // ── Handlers ──────────────────────────────

  Future<void> _onLoadTodos() async {
    _stateController.add(TodoLoading());

    try {
      final todos = await _dbHelper.getAllTodos();
      _todos.clear();
      _todos.addAll(todos);
      _stateController.add(TodoLoaded(List.unmodifiable(_todos)));
    } catch (e) {
      _stateController.add(TodoError('Failed to load todos: $e'));
    }
  }

  Future<void> _onAddTodo(AddTodo event) async {
    if (event.title.trim().isEmpty) {
      _stateController.add(TodoError('Title cannot be empty.'));
      return;
    }

    final newTodo = TodoModel(
      id: _uuid.v4(),
      title: event.title.trim(),
      description: event.description.trim(),
      assignedDate: event.assignedDate,
    );

    try {
      await _dbHelper.insertTodo(newTodo);
      _todos.add(newTodo);
      await _scheduleNotificationIfNeeded(newTodo);
      _stateController.add(
        TodoOperationSuccess(
          message: 'Todo added successfully.',
          todos: List.unmodifiable(_todos),
        ),
      );
    } catch (e) {
      _stateController.add(TodoError('Failed to add todo: $e'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event) async {
    final index = _todos.indexWhere((t) => t.id == event.updatedTodo.id);
    if (index == -1) {
      _stateController.add(TodoError('Todo not found.'));
      return;
    }

    try {
      await _dbHelper.updateTodo(event.updatedTodo);
      _todos[index] = event.updatedTodo;
      await _scheduleNotificationIfNeeded(event.updatedTodo);

      _stateController.add(
        TodoOperationSuccess(
          message: 'Todo updated successfully.',
          todos: List.unmodifiable(_todos),
        ),
      );
    } catch (e) {
      _stateController.add(TodoError('Failed to update todo: $e'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event) async {
    final index = _todos.indexWhere((t) => t.id == event.id);
    if (index == -1) {
      _stateController.add(TodoError('Todo not found.'));
      return;
    }

    try {
      await _dbHelper.delete(event.id);
      _todos.removeAt(index);
      await _cancelNotification(event.id);
      _stateController.add(
        TodoOperationSuccess(
          message: 'Todo deleted successfully.',
          todos: List.unmodifiable(_todos),
        ),
      );
    } catch (e) {
      _stateController.add(TodoError('Failed to delete todo: $e'));
    }
  }

  Future<void> _onToggleComplete(ToggleTodoComplete event) async {
    final index = _todos.indexWhere((t) => t.id == event.id);
    if (index == -1) {
      _stateController.add(TodoError('Todo not found.'));
      return;
    }

    final updatedTodo = _todos[index].copyWith(
      isCompleted: !_todos[index].isCompleted,
    );

    try {
      await _dbHelper.updateTodo(updatedTodo);
      _todos[index] = updatedTodo;

      if (updatedTodo.isCompleted) {
        await _cancelNotification(updatedTodo.id);
      } else {
        await _scheduleNotificationIfNeeded(updatedTodo);
      }

      _stateController.add(
        TodoOperationSuccess(
          message: 'Todo status updated.',
          todos: List.unmodifiable(_todos),
        ),
      );
    } catch (e) {
      _stateController.add(TodoError('Failed to update todo status: $e'));
    }
  }

  void dispose() => _stateController.close();
}
