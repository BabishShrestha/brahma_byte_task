import 'package:flutter/material.dart';

class TabRootScreen extends StatelessWidget {
  final String title;
  final VoidCallback onPush;

  const TabRootScreen({super.key, required this.title, required this.onPush});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blueGrey[50]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Root of $title",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  onPush, // This calls context.read<NavigationCubit>().showDetail()
              child: const Text("Push to Detail Screen"),
            ),
          ],
        ),
      ),
    );
  }
}
