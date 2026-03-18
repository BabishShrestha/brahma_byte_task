import 'package:flutter/material.dart';
import 'package:todo_app/features/nested_bottom_navigation/cubit/nav_cubit.dart';
import 'package:todo_app/features/nested_bottom_navigation/widgets/tab_navigator_widget.dart';

class NestedNavigationView extends StatefulWidget {
  const NestedNavigationView({super.key});

  @override
  State<NestedNavigationView> createState() => _NestedNavigationViewState();
}

class _NestedNavigationViewState extends State<NestedNavigationView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TabNavigator(title: "Item 1", tab: NavbarTab.item1),
          TabNavigator(title: "Item 2", tab: NavbarTab.item2),
          TabNavigator(title: "Item 3", tab: NavbarTab.item3),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Item 1'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Item 2'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Item 3'),
        ],
      ),
    );
  }
}
