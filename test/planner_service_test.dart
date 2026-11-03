import 'package:examorbit/models/difficulty.dart';
import 'package:examorbit/models/study_unit.dart';
import 'package:examorbit/models/subject.dart';
import 'package:examorbit/models/topic.dart';
import 'package:examorbit/services/planner_service.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _today = DateTime(2026, 11, 3);

Subject _subject({
  required String id,
  required DateTime examDate,
  int topics = 4,
  Difficulty difficulty = Difficulty.medium,
  int priority = 3,
  bool completed = false,
}) {
  return Subject(
    id: id,
    name: 'Subject $id',
    examDate: examDate,
    difficulty: difficulty,
    priority: priority,
    units: [
      StudyUnit(
        id: '$id-u1',
        name: 'Unit 1',
        topics: [
          for (var i = 0; i < topics; i++)
            Topic(id: '$id-t$i', name: 'Topic $i', isCompleted: completed),
        ],
      ),
    ],
  );
}

void main() {
  const planner = PlannerService();

  test('returns an empty plan when there are no subjects', () {
    final plan = planner.generatePlan(subjects: const [], today: _today, dailyHours: 2);
    expect(plan.totalTasks, 0);
  });

  test('schedules nothing for a subject with zero topics', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: DateTime(2026, 11, 20), topics: 0)],
      today: _today,
      dailyHours: 2,
    );
    expect(plan.totalTasks, 0);
  });

  test('ignores exams whose date has already passed', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: DateTime(2026, 10, 30))],
      today: _today,
      dailyHours: 2,
    );
    expect(plan.totalTasks, 0);
  });

  test('schedules all pending topics on today when the exam is today', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: _today, topics: 3)],
      today: _today,
      dailyHours: 2,
    );
    expect(plan.tasksOn(_today).length, 3);
    expect(plan.totalTasks, 3);
  });

  test('never schedules on or after the exam day', () {
    final examDay = DateTime(2026, 11, 6);
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: examDay, topics: 6)],
      today: _today,
      dailyHours: 8,
    );
    expect(plan.tasksOn(examDay), isEmpty);
    expect(plan.tasksOn(DateTime(2026, 11, 7)), isEmpty);
    expect(plan.totalTasks, 6);
  });

  test('spreads tasks evenly across the days left before the exam', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: DateTime(2026, 11, 6), topics: 6)],
      today: _today,
      dailyHours: 8,
    );
    for (var offset = 0; offset < 3; offset++) {
      final day = DateTime(2026, 11, 3 + offset);
      expect(plan.tasksOn(day).length, 2, reason: 'day offset $offset');
    }
  });

  test('skips topics that are already completed', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: DateTime(2026, 11, 10), completed: true)],
      today: _today,
      dailyHours: 2,
    );
    expect(plan.totalTasks, 0);
  });

  test('gives harder topics more study minutes than easier ones', () {
    final plan = planner.generatePlan(
      subjects: [
        _subject(id: 'easy', examDate: _today, topics: 1, difficulty: Difficulty.easy),
        _subject(id: 'hard', examDate: _today, topics: 1, difficulty: Difficulty.hard),
      ],
      today: _today,
      dailyHours: 8,
    );
    final minutes = plan.tasksOn(_today).map((task) => task.minutes).toList()..sort();
    expect(minutes, [30, 60]);
  });

  test('keeps every topic even when the daily time budget is too small', () {
    final plan = planner.generatePlan(
      subjects: [_subject(id: 'a', examDate: DateTime(2026, 11, 4), topics: 3)],
      today: _today,
      dailyHours: 0.5,
    );
    expect(plan.totalTasks, 3);
  });
}
