import 'package:todo_app/features/todo/core/db_helper.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

class TodoRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<TodoModel>> fetchTodos() async {
    final todos = await dbHelper.getAllTodos();
    return todos;
  }

  Future<void> addTodo(TodoModel todo) async {
    await dbHelper.insertTodo(todo);
  }

  Future<void> updateTodo(TodoModel todo) async {
    await dbHelper.updateTodo(todo);
  }

  Future<void> deleteTodo(String id) async {
    await dbHelper.delete(id);
  }
}
