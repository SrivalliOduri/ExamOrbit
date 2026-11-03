import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/subject.dart';

typedef StoredData = ({List<Subject> subjects, AppSettings settings});

/// Saves subjects and settings as one JSON document on this device.
class StorageService {
  const StorageService(this._prefs);

  static const _storageKey = 'examorbit_state_v1';

  final SharedPreferences _prefs;

  StoredData load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return _emptyData();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        subjects: [
          for (final item in json['subjects'] as List<dynamic>)
            Subject.fromJson(item as Map<String, dynamic>),
        ],
        settings: AppSettings.fromJson(json['settings'] as Map<String, dynamic>),
      );
    } catch (_) {
      // Unreadable saved data falls back to a fresh start instead of crashing.
      return _emptyData();
    }
  }

  Future<void> save({required List<Subject> subjects, required AppSettings settings}) {
    final payload = jsonEncode({
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
      'settings': settings.toJson(),
    });
    return _prefs.setString(_storageKey, payload);
  }

  StoredData _emptyData() => (subjects: const <Subject>[], settings: const AppSettings.defaults());
}
