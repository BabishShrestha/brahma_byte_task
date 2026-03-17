import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

abstract class TodoBlocState {}

class TodoLoading extends TodoBlocState {}

class TodoLoaded extends TodoBlocState {
  final List<TodoModel> todos;
  TodoLoaded(this.todos);
}

class TodoError extends TodoBlocState {
  final String message;
  TodoError(this.message);
}

class TodoOperationSuccess extends TodoBlocState {
  final String message;
  final List<TodoModel> todos;
  TodoOperationSuccess({required this.message, required this.todos});
}
