import 'package:flutter/material.dart';
import 'package:todo_app/features/todo/core/notification_service.dart';
import 'package:todo_app/features/todo/features/add_todo/view/todo_view.dart';
import 'package:todo_app/features/wrapper.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final NotificationService _notificationService;
  StreamSubscription<String>? _notificationTapSubscription;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService.instance;

    _notificationTapSubscription = _notificationService.notificationTapStream
        .listen(_openTodoFromPayload);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final payload = _notificationService.consumeLaunchPayload();
      if (payload != null && payload.isNotEmpty) {
        _openTodoFromPayload(payload);
      }
    });
  }

  void _openTodoFromPayload(String payload) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => TodoApp(initialTodoId: payload)),
    );
  }

  @override
  void dispose() {
    _notificationTapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(navigatorKey: _navigatorKey, home: const Wrapper());
  }
}
