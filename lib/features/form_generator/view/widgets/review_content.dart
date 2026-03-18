import 'package:flutter/material.dart';

class ReviewContent extends StatelessWidget {
  const ReviewContent({super.key, required this.values});

  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(child: Text('No values entered yet.'));
    }

    final entries = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          dense: true,
          title: Text(entry.key),
          subtitle: Text('${entry.value}'),
        );
      },
    );
  }
}
