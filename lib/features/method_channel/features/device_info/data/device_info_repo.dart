import 'package:flutter/services.dart';
import 'package:todo_app/features/method_channel/features/device_info/domain/model/device_info_model.dart';

class DeviceInfoRepo {
  static const MethodChannel _channel = MethodChannel(
    'com.example.todo_app/device_info',
  );

  Future<DeviceInfoModel> fetchDeviceInfo() async {
    final dynamic raw = await _channel.invokeMethod('getDeviceInfo');
    return DeviceInfoModel.fromMap(raw);
  }

  void setNativeButtonHandler(Future<void> Function() onPressed) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'nativeButtonPressed') {
        await onPressed();
      }
    });
  }

  void clearNativeButtonHandler() {
    _channel.setMethodCallHandler(null);
  }
}
