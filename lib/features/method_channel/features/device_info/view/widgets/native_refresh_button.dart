import 'dart:io';

import 'package:flutter/material.dart';

class NativeRefreshButton extends StatelessWidget {
  const NativeRefreshButton({super.key});

  static const String platformViewType =
      'com.example.todo_app/native_refresh_button';

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const SizedBox(
        height: 56,
        child: AndroidView(viewType: platformViewType),
      );
    }

    if (Platform.isIOS) {
      return const SizedBox(
        height: 56,
        child: UiKitView(viewType: platformViewType),
      );
    }

    return const SizedBox(
      height: 56,
      child: Center(
        child: Text('Native platform button is only available on Android/iOS'),
      ),
    );
  }
}
