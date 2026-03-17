import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/features/add_todo/bloc/todo_bloc.dart';
import 'package:todo_app/features/todo/features/add_todo/bloc/todo_event.dart';
import 'package:todo_app/features/todo/features/add_todo/bloc/todo_state.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';
import 'package:todo_app/features/todo/features/add_todo/view/widgets/todo_detail_view.dart';
import 'package:todo_app/features/todo/features/add_todo/view/widgets/todo_list_view.dart';
import 'package:todo_app/features/todo/features/add_todo/view/widgets/todo_state_views.dart';

class TodoApp extends StatefulWidget {
  final String? initialTodoId;

  const TodoApp({super.key, this.initialTodoId});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TodoBloc _bloc = TodoBloc();
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    _bloc.dispatch(LoadTodos());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Future<void> _openTodoDetail({TodoModel? existing}) async {
    final result = await Navigator.of(context).push<TodoDetailResult>(
      MaterialPageRoute(builder: (_) => TodoDetailView(existing: existing)),
    );

    if (result == null) {
      return;
    }

    if (result.type == TodoDetailActionType.delete) {
      if (existing != null) {
        _bloc.dispatch(DeleteTodo(existing.id));
      }
      return;
    }

    if (result.title == null ||
        result.description == null ||
        result.assignedDate == null) {
      return;
    }

    if (existing == null) {
      _bloc.dispatch(
        AddTodo(
          title: result.title!,
          description: result.description!,
          assignedDate: result.assignedDate!,
        ),
      );
      return;
    }

    _bloc.dispatch(
      UpdateTodo(
        existing.copyWith(
          title: result.title!,
          description: result.description!,
          assignedDate: result.assignedDate!,
        ),
      ),
    );
  }

  List<TodoModel> _resolveTodos(TodoBlocState state) {
    if (state is TodoLoaded) {
      return state.todos;
    }

    if (state is TodoOperationSuccess) {
      return state.todos;
    }

    return const <TodoModel>[];
  }

  void _handleInitialDeepLink(List<TodoModel> todos) {
    if (_deepLinkHandled || widget.initialTodoId == null) {
      return;
    }

    final index = todos.indexWhere((todo) => todo.id == widget.initialTodoId);
    if (index == -1) {
      _deepLinkHandled = true;
      return;
    }

    _deepLinkHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openTodoDetail(existing: todos[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: StreamBuilder<TodoBlocState>(
        stream: _bloc.stream,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state == null || state is TodoLoading) {
            return const TodoLoadingView();
          }

          if (state is TodoError) {
            return TodoErrorView(
              message: state.message,
              onRetry: () => _bloc.dispatch(LoadTodos()),
            );
          }

          final todos = _resolveTodos(state);
          _handleInitialDeepLink(todos);

          if (todos.isEmpty) {
            return const TodoEmptyView();
          }

          return TodoListView(
            todos: todos,
            onToggleComplete: (id) => _bloc.dispatch(ToggleTodoComplete(id)),
            onOpen: (todo) => _openTodoDetail(existing: todo),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTodoDetail(),
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
