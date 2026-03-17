import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/core/utils.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

enum TodoDetailActionType { save, delete }

class TodoDetailResult {
  final TodoDetailActionType type;
  final String? title;
  final String? description;
  final DateTime? assignedDate;

  const TodoDetailResult._({
    required this.type,
    this.title,
    this.description,
    this.assignedDate,
  });

  factory TodoDetailResult.save({
    required String title,
    required String description,
    required DateTime assignedDate,
  }) {
    return TodoDetailResult._(
      type: TodoDetailActionType.save,
      title: title,
      description: description,
      assignedDate: assignedDate,
    );
  }

  factory TodoDetailResult.delete() {
    return const TodoDetailResult._(type: TodoDetailActionType.delete);
  }
}

class TodoDetailView extends StatefulWidget {
  final TodoModel? existing;

  const TodoDetailView({super.key, this.existing});

  @override
  State<TodoDetailView> createState() => _TodoDetailViewState();
}

class _TodoDetailViewState extends State<TodoDetailView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _assignedDate;
  late TimeOfDay _assignedTime;

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _assignedDate = existing?.assignedDate ?? DateTime.now();
    _assignedTime = TimeOfDay.fromDateTime(
      existing?.assignedDate ?? DateTime.now(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectAssignedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Task Date',
    );

    if (picked != null) {
      setState(() {
        _assignedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _assignedTime.hour,
          _assignedTime.minute,
        );
      });
    }
  }

  Future<void> _selectAssignedTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _assignedTime,
      helpText: 'Select Task Time',
    );

    if (picked != null) {
      setState(() {
        _assignedTime = picked;
        _assignedDate = DateTime(
          _assignedDate.year,
          _assignedDate.month,
          _assignedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      TodoDetailResult.save(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedDate: _assignedDate,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Delete "${widget.existing?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.of(context).pop(TodoDetailResult.delete());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Todo' : 'Add Todo'),
        actions: [
          if (_isEditMode)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Task Date'),
                      subtitle: Text(Utils.formatTodoDate(_assignedDate)),
                      onTap: _selectAssignedDate,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Task Time'),
                      subtitle: Text(_assignedTime.format(context)),
                      onTap: _selectAssignedTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditMode ? 'Update Todo' : 'Add Todo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
