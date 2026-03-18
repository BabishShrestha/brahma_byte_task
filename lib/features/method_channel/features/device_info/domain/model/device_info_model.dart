class DeviceInfoModel {
  const DeviceInfoModel({
    required this.batteryLevel,
    required this.deviceModel,
    required this.isCharging,
    required this.systemTime,
    required this.rawSystemTime,
  });

  final int batteryLevel;
  final String deviceModel;
  final bool isCharging;
  final DateTime systemTime;
  final String rawSystemTime;

  factory DeviceInfoModel.fromMap(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('Expected a map from native platform');
    }

    final int? batteryLevel = _toInt(raw['batteryLevel']);
    final String? deviceModel = raw['deviceModel']?.toString();
    final bool? isCharging = _toBool(raw['isCharging']);
    final String? systemTimeRaw = raw['systemTime']?.toString();

    if (batteryLevel == null ||
        deviceModel == null ||
        isCharging == null ||
        systemTimeRaw == null) {
      throw const FormatException('Native data is missing required fields');
    }

    return DeviceInfoModel(
      batteryLevel: batteryLevel,
      deviceModel: deviceModel,
      isCharging: isCharging,
      systemTime: DateTime.parse(systemTimeRaw),
      rawSystemTime: systemTimeRaw,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    final String normalized = value?.toString().toLowerCase() ?? '';
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }
}
