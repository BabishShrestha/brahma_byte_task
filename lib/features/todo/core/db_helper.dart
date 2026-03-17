import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL,
        assignedDate TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Reserved for future migrations.
  }

  // --- CRUD Operations ---

  Future<void> insertTodo(TodoModel todo) async {
    final db = await instance.database;
    await db.insert('todos', {
      'id': todo.id,
      'title': todo.title,
      'description': todo.description,
      'isCompleted': todo.isCompleted ? 1 : 0,
      'assignedDate': todo.assignedDate.toIso8601String(),
    });
  }

  Future<List<TodoModel>> getAllTodos() async {
    final db = await instance.database;
    final result = await db.query('todos');

    return result
        .map(
          (json) => TodoModel(
            id: json['id'] as String,
            title: json['title'] as String,
            description: json['description'] as String,
            isCompleted: json['isCompleted'] == 1,
            assignedDate: DateTime.parse(json['assignedDate'] as String),
          ),
        )
        .toList();
  }

  Future<void> updateTodo(TodoModel todo) async {
    final db = await instance.database;
    await db.update(
      'todos',
      {
        'title': todo.title,
        'description': todo.description,
        'isCompleted': todo.isCompleted ? 1 : 0,
        'assignedDate': todo.assignedDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await instance.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
