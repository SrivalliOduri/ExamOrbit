import 'difficulty.dart';
import 'study_unit.dart';

/// A course the student is preparing for, with its exam date and syllabus.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.examDate,
    required this.difficulty,
    required this.priority,
    required this.units,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        examDate: DateTime.parse(json['examDate'] as String),
        difficulty: Difficulty.values.byName(json['difficulty'] as String),
        priority: json['priority'] as int,
        units: [
          for (final item in json['units'] as List<dynamic>)
            StudyUnit.fromJson(item as Map<String, dynamic>),
        ],
      );

  final String id;
  final String name;
  final DateTime examDate;
  final Difficulty difficulty;

  /// Importance on a 1 (low) to 5 (high) scale.
  final int priority;
  final List<StudyUnit> units;

  int get totalTopics => units.fold(0, (sum, unit) => sum + unit.topics.length);

  int get completedTopics => units.fold(0, (sum, unit) => sum + unit.completedCount);

  double get progress => totalTopics == 0 ? 0 : completedTopics / totalTopics;

  Subject copyWith({
    String? name,
    DateTime? examDate,
    Difficulty? difficulty,
    int? priority,
    List<StudyUnit>? units,
  }) =>
      Subject(
        id: id,
        name: name ?? this.name,
        examDate: examDate ?? this.examDate,
        difficulty: difficulty ?? this.difficulty,
        priority: priority ?? this.priority,
        units: units ?? this.units,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'examDate': examDate.toIso8601String(),
        'difficulty': difficulty.name,
        'priority': priority,
        'units': units.map((unit) => unit.toJson()).toList(),
      };
}
