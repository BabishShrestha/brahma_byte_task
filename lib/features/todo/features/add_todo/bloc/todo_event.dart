import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  final String description;
  final DateTime assignedDate;

  AddTodo({
    required this.title,
    required this.description,
    required this.assignedDate,
  });
}

class UpdateTodo extends TodoEvent {
  final TodoModel updatedTodo;
  UpdateTodo(this.updatedTodo);
}

class DeleteTodo extends TodoEvent {
  final String id;
  DeleteTodo(this.id);
}

class ToggleTodoComplete extends TodoEvent {
  final String id;
  ToggleTodoComplete(this.id);
}
