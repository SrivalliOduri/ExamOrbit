import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../services/planner_service.dart';
import '../services/storage_service.dart';
import '../utils/date_helpers.dart';
import '../utils/id_generator.dart';

/// Holds subjects and settings for the whole app and saves every change to the device.
class AppState extends ChangeNotifier {
  AppState({
    required StorageService storage,
    required List<Subject> subjects,
    required AppSettings settings,
  })  : _storage = storage,
        _subjects = subjects,
        _settings = settings;

  final StorageService _storage;
  final PlannerService _planner = const PlannerService();
  List<Subject> _subjects;
  AppSettings _settings;

  List<Subject> get subjects => List.unmodifiable(_subjects);

  AppSettings get settings => _settings;

  int get totalTopics => _subjects.fold(0, (sum, subject) => sum + subject.totalTopics);

  int get completedTopics => _subjects.fold(0, (sum, subject) => sum + subject.completedTopics);

  double get overallProgress => totalTopics == 0 ? 0 : completedTopics / totalTopics;

  DailyPlan get todayPlan => _planner.generatePlan(
        subjects: _subjects,
        today: DateTime.now(),
        dailyHours: _settings.dailyStudyHours,
      );

  Subject? get nextExam {
    final today = dateOnly(DateTime.now());
    Subject? next;
    for (final subject in _subjects) {
      if (daysBetween(today, subject.examDate) < 0) continue;
      if (next == null || subject.examDate.isBefore(next.examDate)) next = subject;
    }
    return next;
  }

  Subject? subjectById(String id) {
    for (final subject in _subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  void addSubject(Subject subject) {
    _subjects = [..._subjects, subject];
    _commit();
  }

  void updateSubject(Subject subject) {
    _subjects = [for (final item in _subjects) item.id == subject.id ? subject : item];
    _commit();
  }

  void addTopic({required String subjectId, required String unitId, required String name}) {
    _subjects = [
      for (final subject in _subjects)
        if (subject.id == subjectId)
          subject.copyWith(units: [
            for (final unit in subject.units)
              if (unit.id == unitId)
                unit.copyWith(topics: [...unit.topics, Topic(id: newId(), name: name)])
              else
                unit,
          ])
        else
          subject,
    ];
    _commit();
  }

  void toggleTopic(String topicId) {
    _subjects = [
      for (final subject in _subjects)
        _mapTopics(
          subject,
          (topic) => topic.id == topicId
              ? topic.copyWith(isCompleted: !topic.isCompleted)
              : topic,
        ),
    ];
    _commit();
  }

  void setDarkMode(bool isDark) {
    _settings = _settings.copyWith(isDarkMode: isDark);
    _commit();
  }

  void setDailyHours(double hours) {
    _settings = _settings.copyWith(dailyStudyHours: hours);
    _commit();
  }

  void resetAll() {
    _subjects = const [];
    _settings = const AppSettings.defaults();
    _commit();
  }

  Subject _mapTopics(Subject subject, Topic Function(Topic topic) transform) => subject.copyWith(
        units: [
          for (final unit in subject.units)
            unit.copyWith(topics: [for (final topic in unit.topics) transform(topic)]),
        ],
      );

  void _commit() {
    notifyListeners();
    unawaited(_storage.save(subjects: _subjects, settings: _settings));
  }
}
