import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/nested_bottom_navigation/cubit/nav_cubit.dart';

class TabDetailView extends StatelessWidget {
  final String title;
  const TabDetailView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<NavigationCubit>().showRoot();
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Container(
          color: Colors.amber[50],
          child: Center(
            child: Text(
              "I am a nested screen of $title!\nNotice the Bottom Bar is still here.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
