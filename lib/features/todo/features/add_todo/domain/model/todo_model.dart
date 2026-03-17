class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime assignedDate;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.assignedDate,
  });
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? assignedDate,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedDate: assignedDate ?? this.assignedDate,
    );
  }

  @override
  String toString() =>
      'TodoModel(id: $id, title: $title, isCompleted: $isCompleted)';
}
