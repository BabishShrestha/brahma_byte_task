import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/todo/features/add_todo/domain/model/todo_model.dart';

class TodoDialogResult {
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime? notificationDateTime;

  TodoDialogResult({
    required this.title,
    required this.description,
    required this.assignedDate,
    this.notificationDateTime,
  });
}

Future<TodoDialogResult?> showTodoDialog({
  required BuildContext context,
  TodoModel? existing,
}) {
  return showDialog<TodoDialogResult>(
    context: context,
    builder: (context) => TodoDialog(existing: existing),
  );
}

class TodoDialog extends StatefulWidget {
  final TodoModel? existing;

  const TodoDialog({super.key, this.existing});

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _assignedDate;
  late TimeOfDay _assignedTime;

  bool _enableNotification = false;
  DateTime? _notificationDateTime;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );

    _assignedDate = existing?.assignedDate ?? DateTime.now();
    _assignedTime = TimeOfDay.fromDateTime(_assignedDate);

    _notificationDateTime = existing?.assignedDate;
    _enableNotification = _notificationDateTime != null;
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Select Task Date',
    );

    if (picked != null) {
      setState(() {
        _assignedDate = picked;
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
      });
    }
  }

  Future<void> _selectNotificationDateTime() async {
    // First select date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _notificationDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Select Notification Date',
    );

    if (pickedDate == null) return;

    // Then select time
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _notificationDateTime != null
          ? TimeOfDay.fromDateTime(_notificationDateTime!)
          : TimeOfDay.now(),
      helpText: 'Select Notification Time',
    );

    if (pickedTime == null) return;

    setState(() {
      _notificationDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Combine assigned date and time
    final combinedAssignedDate = DateTime(
      _assignedDate.year,
      _assignedDate.month,
      _assignedDate.day,
      _assignedTime.hour,
      _assignedTime.minute,
    );

    // Validate notification time is before assigned time
    if (_enableNotification && _notificationDateTime != null) {
      if (_notificationDateTime!.isAfter(combinedAssignedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification time must be before the task time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_notificationDateTime!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification time must be in the future'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Navigator.of(context).pop(
      TodoDialogResult(
        title: _titleController.text,
        description: _descriptionController.text,
        assignedDate: combinedAssignedDate,
        notificationDateTime: _enableNotification
            ? _notificationDateTime
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    widget.existing == null ? 'Add Todo' : 'Edit Todo',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter task title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter task description',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Task Date and Time Section
                  Text(
                    'Task Schedule',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Assigned Date Picker
                  InkWell(
                    onTap: _selectAssignedDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'EEEE, MMM dd, yyyy',
                                  ).format(_assignedDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Assigned Time Picker
                  InkWell(
                    onTap: _selectAssignedTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Task Time',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _assignedTime.format(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notification Section
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Reminder Notification',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: _enableNotification,
                        onChanged: (value) {
                          setState(() {
                            _enableNotification = value;
                            if (value && _notificationDateTime == null) {
                              // Set default notification time to 30 minutes before task
                              final assignedDateTime = DateTime(
                                _assignedDate.year,
                                _assignedDate.month,
                                _assignedDate.day,
                                _assignedTime.hour,
                                _assignedTime.minute,
                              );
                              _notificationDateTime = assignedDateTime.subtract(
                                const Duration(minutes: 30),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_enableNotification) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _selectNotificationDateTime,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.purple.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm, color: Colors.purple),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notification Time',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _notificationDateTime != null
                                              ? DateFormat(
                                                  'MMM dd, yyyy - hh:mm a',
                                                ).format(_notificationDateTime!)
                                              : 'Tap to set',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _notificationDateTime != null
                                                ? Colors.black87
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_notificationDateTime != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'You will be notified at the selected time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.existing == null ? 'Add' : 'Update',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
