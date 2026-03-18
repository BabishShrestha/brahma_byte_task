import 'package:flutter/material.dart';
import 'package:todo_app/features/form_generator/view/form_view.dart';
import 'package:todo_app/features/method_channel/method_channel_view.dart';
import 'package:todo_app/features/nested_bottom_navigation/nested_navigation_view.dart';
import 'package:todo_app/features/todo/features/add_todo/view/todo_view.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TodoApp()),
                );
              },
              child: const Text('Todo App'),
            ),
          ),
          ElevatedButton(
            child: const Text('Form Generator'),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const FormView()));
            },
          ),
          ElevatedButton(child: const Text('E-Commerce'), onPressed: () {}),
          ElevatedButton(
            child: const Text('Method Channel'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MethodChannelView(),
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Nested Bottom Navigation App'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NestedNavigationView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
