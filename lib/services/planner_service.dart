import '../models/study_task.dart';
import '../models/subject.dart';
import '../models/topic.dart';
import '../utils/date_helpers.dart';

/// Study tasks grouped by calendar day.
class DailyPlan {
  const DailyPlan(this._tasksByDay);

  final Map<DateTime, List<StudyTask>> _tasksByDay;

  List<StudyTask> tasksOn(DateTime day) => _tasksByDay[dateOnly(day)] ?? const [];

  int get totalTasks => _tasksByDay.values.fold(0, (sum, tasks) => sum + tasks.length);
}

/// Spreads pending topics across the days left before each exam.
///
/// Difficulty sets how many minutes a topic needs. Priority decides which topics
/// are placed first, so important subjects get the lightest days.
class PlannerService {
  const PlannerService({this.baseMinutesPerTopic = 30});

  final int baseMinutesPerTopic;

  DailyPlan generatePlan({
    required List<Subject> subjects,
    required DateTime today,
    required double dailyHours,
  }) {
    final start = dateOnly(today);
    final capacityMinutes = dailyHours * 60;
    final pending = _pendingTopics(subjects, start)..sort(_byUrgency);

    final loadByOffset = <int, int>{};
    final assignedByOffset = <int, List<_PendingTopic>>{};
    for (final item in pending) {
      final offset = _pickDay(item, loadByOffset, capacityMinutes);
      loadByOffset[offset] = (loadByOffset[offset] ?? 0) + item.minutes;
      assignedByOffset.putIfAbsent(offset, () => []).add(item);
    }

    final tasksByDay = <DateTime, List<StudyTask>>{};
    assignedByOffset.forEach((offset, items) {
      items.sort((a, b) => b.subject.priority.compareTo(a.subject.priority));
      tasksByDay[DateTime(start.year, start.month, start.day + offset)] = [
        for (final item in items)
          StudyTask(
            subjectId: item.subject.id,
            subjectName: item.subject.name,
            topicId: item.topic.id,
            topicName: item.topic.name,
            minutes: item.minutes,
          ),
      ];
    });
    return DailyPlan(tasksByDay);
  }

  List<_PendingTopic> _pendingTopics(List<Subject> subjects, DateTime start) {
    final result = <_PendingTopic>[];
    for (final subject in subjects) {
      final daysLeft = daysBetween(start, subject.examDate);
      if (daysLeft < 0) continue;
      // An exam today still leaves today as a study day.
      final studyDays = daysLeft == 0 ? 1 : daysLeft;
      final minutes = (baseMinutesPerTopic * subject.difficulty.effortMultiplier).round();
      for (final unit in subject.units) {
        for (final topic in unit.topics) {
          if (topic.isCompleted) continue;
          result.add(_PendingTopic(
            subject: subject,
            topic: topic,
            studyDays: studyDays,
            minutes: minutes,
          ));
        }
      }
    }
    return result;
  }

  int _byUrgency(_PendingTopic a, _PendingTopic b) {
    final byDeadline = a.studyDays.compareTo(b.studyDays);
    if (byDeadline != 0) return byDeadline;
    final byPriority = b.subject.priority.compareTo(a.subject.priority);
    if (byPriority != 0) return byPriority;
    return b.minutes.compareTo(a.minutes);
  }

  /// Picks the least-loaded day that still fits the topic; falls back to the least-loaded day overall.
  int _pickDay(_PendingTopic item, Map<int, int> loadByOffset, double capacityMinutes) {
    int loadOf(int offset) => loadByOffset[offset] ?? 0;

    int? bestFit;
    var bestAny = 0;
    for (var offset = 0; offset < item.studyDays; offset++) {
      if (loadOf(offset) < loadOf(bestAny)) bestAny = offset;
      final fits = loadOf(offset) + item.minutes <= capacityMinutes;
      if (fits && (bestFit == null || loadOf(offset) < loadOf(bestFit))) {
        bestFit = offset;
      }
    }
    return bestFit ?? bestAny;
  }
}

class _PendingTopic {
  const _PendingTopic({
    required this.subject,
    required this.topic,
    required this.studyDays,
    required this.minutes,
  });

  final Subject subject;
  final Topic topic;
  final int studyDays;
  final int minutes;
}
