import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FormLocalStorage {
  static const String _storageKey = 'car_insurance_form_progress_v1';

  Future<void> saveProgress({
    required int stepIndex,
    required Map<String, dynamic> values,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(<String, dynamic>{
      'stepIndex': stepIndex,
      'values': values,
      'savedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_storageKey, payload);
  }

  Future<FormProgressSnapshot?> readProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }

      final map = Map<String, dynamic>.from(decoded);
      final stepIndex = _asInt(map['stepIndex']);
      final valuesRaw = map['values'];
      final values = valuesRaw is Map
          ? Map<String, dynamic>.from(valuesRaw)
          : <String, dynamic>{};
      final savedAtRaw = map['savedAt']?.toString();

      return FormProgressSnapshot(
        stepIndex: stepIndex,
        values: values,
        savedAt: savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class FormProgressSnapshot {
  const FormProgressSnapshot({
    required this.stepIndex,
    required this.values,
    required this.savedAt,
  });

  final int stepIndex;
  final Map<String, dynamic> values;
  final DateTime? savedAt;

  bool get hasProgress => stepIndex > 0 || values.isNotEmpty;
}
