import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/nested_bottom_navigation/cubit/nav_cubit.dart';
import 'package:todo_app/features/nested_bottom_navigation/widgets/tab_detail_view.dart';
import 'package:todo_app/features/nested_bottom_navigation/widgets/tab_root_view.dart';

class TabNavigator extends StatelessWidget {
  final String title;
  final NavbarTab tab;

  const TabNavigator({super.key, required this.title, required this.tab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return Navigator(
            pages: [
              MaterialPage(
                child: TabRootScreen(
                  title: title,
                  onPush: () => context.read<NavigationCubit>().showDetail(),
                ),
              ),
              if (state is NavigationDetail)
                MaterialPage(child: TabDetailView(title: title)),
            ],
            onDidRemovePage: (page) {
              context.read<NavigationCubit>().showRoot();
            },
          );
        },
      ),
    );
  }
}
