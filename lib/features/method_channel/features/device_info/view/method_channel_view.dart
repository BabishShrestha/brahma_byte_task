import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/method_channel/features/device_info/cubit/device_info_cubit.dart';
import 'package:todo_app/features/method_channel/features/device_info/cubit/device_info_state.dart';
import 'package:todo_app/features/method_channel/features/device_info/data/device_info_repo.dart';
import 'package:todo_app/features/method_channel/features/device_info/view/widgets/native_refresh_button.dart';

class MethodChannelView extends StatefulWidget {
  const MethodChannelView({super.key});

  @override
  State<MethodChannelView> createState() => _MethodChannelViewState();
}

class _MethodChannelViewState extends State<MethodChannelView> {
  late final DeviceInfoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DeviceInfoCubit(DeviceInfoRepo());
    _cubit.startNativeButtonListener();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Method Channel + Platform View')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<DeviceInfoCubit, DeviceInfoState>(
            builder: (context, state) {
              final info = state.info;
              final formattedTime = info == null
                  ? '-'
                  : DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(info.systemTime.toLocal());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () =>
                              context.read<DeviceInfoCubit>().fetchDeviceInfo(),
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      state.isLoading
                          ? 'Fetching...'
                          : 'Fetch Native JSON Data',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Native PlatformView Button (refreshes battery data):',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const NativeRefreshButton(),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            label: 'Battery Level',
                            value: info == null ? '-' : '${info.batteryLevel}%',
                          ),
                          _InfoRow(
                            label: 'Device Model',
                            value: info?.deviceModel ?? '-',
                          ),
                          _InfoRow(
                            label: 'Is Charging',
                            value: info == null
                                ? '-'
                                : (info.isCharging ? 'Yes' : 'No'),
                          ),
                          _InfoRow(label: 'System Time', value: formattedTime),
                          _InfoRow(
                            label: 'Raw ISO Time',
                            value: info?.rawSystemTime ?? '-',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
