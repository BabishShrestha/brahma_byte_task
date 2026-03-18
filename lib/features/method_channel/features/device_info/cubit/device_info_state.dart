import 'package:todo_app/features/method_channel/features/device_info/domain/model/device_info_model.dart';

class DeviceInfoState {
  const DeviceInfoState({this.isLoading = false, this.info, this.error});

  final bool isLoading;
  final DeviceInfoModel? info;
  final String? error;

  DeviceInfoState copyWith({
    bool? isLoading,
    DeviceInfoModel? info,
    String? error,
    bool clearError = false,
  }) {
    return DeviceInfoState(
      isLoading: isLoading ?? this.isLoading,
      info: info ?? this.info,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
