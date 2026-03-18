import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/features/method_channel/features/device_info/data/device_info_repo.dart';
import 'package:todo_app/features/method_channel/features/device_info/cubit/device_info_state.dart';

class DeviceInfoCubit extends Cubit<DeviceInfoState> {
  DeviceInfoCubit(this._repo) : super(const DeviceInfoState());

  final DeviceInfoRepo _repo;

  void startNativeButtonListener() {
    _repo.setNativeButtonHandler(() async {
      await fetchDeviceInfo();
    });
  }

  Future<void> fetchDeviceInfo() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final info = await _repo.fetchDeviceInfo();
      emit(state.copyWith(isLoading: false, info: info, clearError: true));
    } on PlatformException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.message ?? 'Platform error while fetching device info',
        ),
      );
    } on FormatException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Unexpected error: $e'));
    }
  }

  @override
  Future<void> close() {
    _repo.clearNativeButtonHandler();
    return super.close();
  }
}
