import 'topic.dart';

/// A chapter or module of a subject that groups related topics.
class StudyUnit {
  const StudyUnit({required this.id, required this.name, required this.topics});

  factory StudyUnit.fromJson(Map<String, dynamic> json) => StudyUnit(
        id: json['id'] as String,
        name: json['name'] as String,
        topics: [
          for (final item in json['topics'] as List<dynamic>)
            Topic.fromJson(item as Map<String, dynamic>),
        ],
      );

  final String id;
  final String name;
  final List<Topic> topics;

  int get completedCount => topics.where((topic) => topic.isCompleted).length;

  double get progress => topics.isEmpty ? 0 : completedCount / topics.length;

  StudyUnit copyWith({List<Topic>? topics}) => StudyUnit(
        id: id,
        name: name,
        topics: topics ?? this.topics,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'topics': topics.map((topic) => topic.toJson()).toList(),
      };
}
