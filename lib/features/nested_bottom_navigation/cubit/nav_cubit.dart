import 'package:bloc/bloc.dart';

enum NavbarTab { item1, item2, item3 }

abstract class NavigationState {}

class NavigationRoot extends NavigationState {}

class NavigationDetail extends NavigationState {}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationRoot());

  void showDetail() => emit(NavigationDetail());
  void showRoot() => emit(NavigationRoot());
}
